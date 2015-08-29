#!/usr/bin/env ruby

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
        @jira.get('/project').map { |entry| entry['key'] }
    end

    def list_project_issues(params)
        @jira.get("/search?fields=key&jql=project%3D#{params[:project]}")['issues'].map { |entry| entry['key'] }
    end

    def list_issue_comments(params)
        comments = @jira.get("/issue/#{params[:issue]}/comment")['comments'].map { |entry| entry['id'] }
        return comments.map { |id| id+'.txt' } + comments.map { |id| id+'.json' }
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

    def read_issue(params)
        @jira.get("/issue/#{params[:issue]}?fields=attachment")
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

    route_add :list, '/', to: [ 'projects' ]
     route_add :list, '/projects', to: :list_projects
      route_add :list, '/projects/:project', to: [ 'issues' ]
       route_add :list, '/projects/:project/issues', to: :list_project_issues
        route_add :list, '/projects/:project/issues/:issue', to: [ 'comments', 'attachments' ]
         route_add :list, '/projects/:project/issues/:issue/comments', to: :list_issue_comments
          route_add :read, '/projects/:project/issues/:issue/comments/:comment.txt', to: :read_issue_comment_body
          route_add :read, '/projects/:project/issues/:issue/comments/:comment.json', to: :read_issue_comment_json
         route_add :list, '/projects/:project/issues/:issue/attachments', to: :list_issue_attachments
          route_add :read, '/projects/:project/issues/:issue/attachments/:attachment.json', to: :read_attachment_json
          route_add :list, '/projects/:project/issues/:issue/attachments/:attachment', to: :list_attachment_body, constraints: { attachment: /[^\/.]+/ }
           route_add :read, '/projects/:project/issues/:issue/attachments/:attachment/:filename', to: :read_attachment_body
end
