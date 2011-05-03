(function($){
$(document).ready(function(){
  function split( val ) {
    return val.split( /,\s*/ );
  }
  function extractLast( term ) {
    return split( term ).pop();
  }

  // The iterator is needed beacuse the data method only acts on the
  // first member of a collection by default http://docs.jquery.com/Data
  // Code inspired by:
  //   http://jqueryui.com/demos/autocomplete/#multiple
  //   http://jqueryui.com/demos/autocomplete/#custom-data
  $.each(
    $( '.multiple-ldap-autocomplete' )
      // don't navigate away from the field on tab when selecting an item
      .bind( 'keydown', function( event ) {
        if ( event.keyCode === $.ui.keyCode.TAB && $(this).data( 'autocomplete' ).menu.active ) {
          event.preventDefault();
        }
      })
      .autocomplete({
        source: function( request, response ) {
          $.getJSON( '/ldap_query', {
            term: extractLast( request.term )
          }, response );
        },
        search: function() {
          // custom minLength
          var term = extractLast( this.value );
          if ( term.length < 2 ) {
            return false;
          }
        },
        focus: function() {
          // prevent value inserted on focus
          return false;
        },
        select: function( event, ui ) {
          var terms = split( this.value );
          // remove the current input
          terms.pop();
          // add the selected item
          terms.push( ui.item.netid );
          // add placeholder to get the comma-and-space at the end
          terms.push( '' );
          this.value = terms.join( ', ' );
          return false;
        }
      }), function(){
      $(this).data( 'autocomplete' )._renderItem = function( ul, item ) {
        return $( '<li></li>' )
          .data( 'item.autocomplete', item )
          .append( '<a>' +  item.name + ' (' + item.netid + ')</a>' )
          .appendTo( ul );
        };
      }
    );

  $.each(
    $( '.ldap-autocomplete' )
      .autocomplete({
        source: function( request, response ) {
          $.getJSON( '/ldap_query', {
            term: extractLast( request.term )
          }, response );
        },
        minLength: 3,
        focus: function() {
          // prevent value inserted on focus
          return false;
        },
        select: function( event, ui ) {
          this.value = ui.item.name + ' (' + ui.item.netid + ')';
          return false;
        }
      }), function(){
      $(this).data( 'autocomplete' )._renderItem = function( ul, item ) {
        return $( '<li></li>' )
          .data( 'item.autocomplete', item )
          .append( '<a>' +  item.name + ' (' + item.netid + ')</a>' )
          .appendTo( ul );
        };
      }
    );

});
})(jQuery);
