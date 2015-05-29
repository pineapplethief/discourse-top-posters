export default Ember.Component.extend({
  classNames: ['top-posters-container'],
  classNameBindings: ['loaded'],

  posters: [],

  expanded: true,

  actions: {
    postersToggle: function() {
      this.toggleProperty('expanded');
    }
  },

  loaded: function() {
    return (this.get('posters').length > 0);
  }.property('posters'),

  iconClass: function() {
    if (this.get('expanded')) { return "fa fa-caret-up"; }
    return "fa fa-caret-down";
  }.property('expanded'),

  populatePosters: function() {
    var self = this;

    Discourse.ajax("/top_posters", { type: 'GET' })
             .then(function(response) {
                var posters = response.top_posters.map(function(poster){
                  return Discourse.User.create(poster);
                });
                self.set('posters', posters);
                self.set('classNames', ['top-posters-container', 'loaded']);
             });

  }.on('init'),

});
