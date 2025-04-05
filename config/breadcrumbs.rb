# crumb :root do
#  link "Home", root_path
# end

# crumb :projects do
#   link "Projects", projects_path
# end

# crumb :project do |project|
#   link project.name, project_path(project)
#   parent :projects
# end

# crumb :project_issues do |project|
#   link "Issues", project_issues_path(project)
#   parent :project, project
# end

# crumb :issue do |issue|
#   link issue.title, issue_path(issue)
#   parent :project_issues, issue.project
# end

# If you want to split your breadcrumbs configuration over multiple files, you
# can create a folder named `config/breadcrumbs` and put your configuration
# files there. All *.rb files (e.g. `frontend.rb` or `products.rb`) in that
# folder are loaded and reloaded automatically when you change them, just like
# this file (`config/breadcrumbs.rb`).

crumb :dashboard do
  link '<i class="fa fa-dashboard"></i> Dashboard'.html_safe, dashboard_index_path
end

crumb :goals_index do
  link '<i class="fas fa-tasks mr-2"></i>目標一覧'.html_safe, goals_path
  parent :dashboard
end

crumb :goal_new do
  link "作成", new_goal_path
  parent :goals_index
end

crumb :goal_show do
  link "詳細", goal_path
  parent :goals_index
end

crumb :goal_edit do
  link "編集", edit_goal_path
  parent :goal_show
end

crumb :users_show do
  link '<i class="fas fa-user mr-2"></i>ユーザー情報'.html_safe, users_show_path
  parent :dashboard
end

crumb :users_edit do
  link "編集", edit_user_registration_path
  parent :users_show
end

crumb :users_password_reset do
  link "パスワード変更", edit_user_registration_path
  parent :users_show
end

crumb :openchat do
  link '<i class="fas fa-comments mr-1"></i>チャット'.html_safe, tweet_index_path
  parent :dashboard
end
