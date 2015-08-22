#!/usr/bin/env ruby

require 'time'
require './routeddir'
require './jira'

def to_json(object)
    "#{JSON.pretty_generate(object)}\n\n" # TODO: figure out why 2 characters are cut off the end
end

class JiraDir < RoutedDir
    def initialize
        @jira = Jira.new
    end

    def list_projects(params)
        @jira.get('/project', max_age: 1800).map { |entry| entry['key'] }
    end

    def list_project_issues(params)
        @jira.get("/search?fields=key&jql=project%3D#{params[:project]}")['issues'].map { |entry| entry['key'] }
    end

    def list_issue_comments(params)
        comments = @jira.get("/issue/#{params[:issue]}/comment")['comments'].map { |entry| entry['id'] }
        return comments.map { |id| id+'.txt' } + comments.map { |id| id+'.json' } + [ 'new' ]
    end

    def read_issue_comment(params)
        @jira.get("/issue/#{params[:issue]}/comment/#{params[:comment]}")
    end

    def read_issue_comment_json(params)
        to_json(read_issue_comment(params))
    end

    def read_issue_comment_body(params)
        read_issue_comment(params)['body']
    end

    def get_issue_comment_times(params)
        comment = read_issue_comment(params)

        ctime = Time.parse(comment['created']).to_i
        mtime = Time.parse(comment['updated']).to_i
        atime = mtime

        return [ atime, mtime, ctime ]
    end

    def add_comment(params, contents)
        return if contents.empty?
        @jira.post("/issue/#{params[:issue]}/comment", body: { 'body' => contents }.to_json)
    end

    def read_issue(params)
        @jira.get("/issue/#{params[:issue]}?fields=attachment,description")
    end

    def list_issue_attachments(params)
        attachments = read_issue(params)['fields']['attachment'].map { |entry| entry['id'] }
        return attachments + attachments.map { |id| id+'.json' }
    end

    def read_attachment(params)
        @jira.get("/attachment/#{params[:attachment]}")
    end

    def read_attachment_json(params)
        to_json(read_attachment(params))
    end

    def list_attachment_body(params)
        [ read_attachment(params)['filename'] ]
    end

    def read_attachment_body(params)
        @jira.raw_get(read_attachment(params)['content'])
    end

    def get_issue_attachment_times(params)
        attachment = read_attachment(params)

        ctime = Time.parse(attachment['created']).to_i
        mtime = ctime
        atime = mtime

        return [ atime, mtime, ctime ]
    end

    def get_attachment_body_size(params)
        read_attachment(params)['size']
    end

    def read_issue_title(params)
        read_issue(params)['fields']['description']
    end

    route_add :list, '/', to: [ 'projects' ]
     route_add :list, '/projects', to: :list_projects
      route_add :list, '/projects/:project', to: [ 'issues' ]
       route_add :list, '/projects/:project/issues', to: :list_project_issues
        route_add :list, '/projects/:project/issues/:issue', to: [ 'comments', 'attachments', 'metadata' ]
         route_add :list, '/projects/:project/issues/:issue/comments', to: :list_issue_comments
          route_add :read, '/projects/:project/issues/:issue/comments/:comment.txt', to: :read_issue_comment_body
          route_add :times, '/projects/:project/issues/:issue/comments/:comment.txt', to: :get_issue_comment_times
          route_add :read, '/projects/:project/issues/:issue/comments/:comment.json', to: :read_issue_comment_json
          route_add :times, '/projects/:project/issues/:issue/comments/:comment.json', to: :get_issue_comment_times
          route_add :read, '/projects/:project/issues/:issue/comments/new', to: ""
          route_add :write, '/projects/:project/issues/:issue/comments/new', to: :add_comment
         route_add :list, '/projects/:project/issues/:issue/attachments', to: :list_issue_attachments
          route_add :read, '/projects/:project/issues/:issue/attachments/:attachment.json', to: :read_attachment_json
          route_add :times, '/projects/:project/issues/:issue/attachments/:attachment.json', to: :get_issue_attachment_times
          route_add :list, '/projects/:project/issues/:issue/attachments/:attachment', to: :list_attachment_body, constraints: { attachment: /[^\/.]+/ }
          route_add :times, '/projects/:project/issues/:issue/attachments/:attachment', to: :get_issue_attachment_times, constraints: { attachment: /[^\/.]+/ }
           route_add :read, '/projects/:project/issues/:issue/attachments/:attachment/:filename', to: :read_attachment_body
           route_add :size, '/projects/:project/issues/:issue/attachments/:attachment/:filename', to: :get_attachment_body_size
           route_add :times, '/projects/:project/issues/:issue/attachments/:attachment/:filename', to: :get_issue_attachment_times
         route_add :list, '/projects/:project/issues/:issue/metadata', to: [ 'title' ]
          route_add :read, '/projects/:project/issues/:issue/metadata/title', to: :read_issue_title
end
