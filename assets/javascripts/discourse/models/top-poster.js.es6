import RestModel from 'discourse/models/rest';
import avatarTemplate from 'discourse/lib/avatar-template';

const TopPoster = RestModel.extend({});

TopPoster.reopenClass({

  displayName: function() {
    if (Discourse.SiteSettings.enable_names && !this.blank('name')) {
      return this.get('name');
    }
    return this.get('username');
  }.property('username', 'name'),

  path: function(){
    return Discourse.getURL('/users/' + this.get('username_lower'));
    // no need to observe, requires a hard refresh to update
  }.property(),

  avatarTemplate: function() {
    return avatarTemplate(this.get('username'), this.get('uploaded_avatar_id'));
  }.property('uploaded_avatar_id', 'username')

});
