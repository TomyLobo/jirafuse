#!/usr/bin/env ruby

require './routeddir'
require './jira'

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
        # return the HTTP body
        read_issue_comment(params).body
    end

    def read_issue_comment_body(params)
        # return the value for the "body" key in the JSON object in the HTTP body
        read_issue_comment(params)['body']
    end

    route_add :list, '/', to: [ 'projects' ]
     route_add :list, '/projects', to: :list_projects
      route_add :list, '/projects/:project', to: [ 'issues' ]
       route_add :list, '/projects/:project/issues', to: :list_project_issues
        route_add :list, '/projects/:project/issues/:issue', to: [ 'comments' ]
         route_add :list, '/projects/:project/issues/:issue/comments', to: :list_issue_comments
          route_add :read, '/projects/:project/issues/:issue/comments/:comment.txt', to: :read_issue_comment_body
          route_add :read, '/projects/:project/issues/:issue/comments/:comment.json', to: :read_issue_comment_json
end
