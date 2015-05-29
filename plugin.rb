# name: top posters
# about: Plugin for Discourse showing users ranked by number of posts over week
# version: 0.1
# authors: Alexey Glukhov (pineapplethief)
# url: insert url later

enabled_site_setting :top_posters_enabled

register_asset 'stylesheets/common/top_posters.scss'
register_asset 'stylesheets/desktop/top_posters.scss', :desktop
register_asset 'stylesheets/mobile/top_posters.scss', :mobile

register_asset 'javascripts/discourse/templates/discovery.hbs', :server_side
register_asset 'javascripts/discourse/templates/components/top-posters.hbs', :server_side

PLUGIN_NAME ||= "discourse_top_posters".freeze

after_initialize do

  module ::DiscourseTopPosters
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace DiscourseTopPosters
    end
  end


  require_dependency 'basic_user_serializer'
  class DiscourseTopPosters::TopPosterUserSerializer < BasicUserSerializer
    attributes :posts_count
  end

  require_dependency 'application_controller'
  class DiscourseTopPosters::UsersController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def top_posters
      limit = SiteSetting.send(:top_posters_users_to_show).to_i
      users = User.select("#{User.table_name}.*, COUNT(#{Post.table_name}.id) AS posts_count")
                   .joins(:posts)
                   .where("#{User.table_name}.id > 0")
                   .where('NOT EXISTS(SELECT 1
                                      FROM user_custom_fields ucf
                                      WHERE ucf.user_id = users.id AND
                                            ucf.name = ? AND
                                            ucf.value::int > 0
                                      )', 'master_id')
                   .where("#{Post.table_name}.created_at >= ?", 1.week.ago.utc)
                   .activated.not_blocked.not_suspended
                   .merge(Post.visible)
                   .group("#{User.table_name}.id")
                   .order('posts_count DESC')
      users = users.limit(limit) if limit > 0

      render_serialized(users, DiscourseTopPosters::TopPosterUserSerializer, root: 'top_posters')
    end

  end

  # TODO: Write custom controller

  DiscourseTopPosters::Engine.routes.draw do
    get '/' => 'users#top_posters'
  end

  Discourse::Application.routes.append do
    mount ::DiscourseTopPosters::Engine, at: '/top_posters'
  end

end