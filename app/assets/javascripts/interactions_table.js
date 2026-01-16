var dataTablesPropDefault = {
    retrieve: true,
    "bAutoWidth": false,
    stateSave: true,

    "pageLength": 10,
    "order": [],
    "columnDefs": [{
      "targets"  : 'no-sort',
      "orderable": false,
      },
      {"targets"    : [ 3,4,7,8 ],
       "visible"    : false},
       {"width": "2%", "targets": [9]},
      {"width": "3%", "targets": [1,3,5,7]}],
    "drawCallback": function(){

        $('[data-toggle="ajax-popover"]').popover({
          container: 'body',
          placement : 'top',
            trigger : 'click',
            html : true,
        });
        $('[data-toggle="ajax-tooltip"]').tooltip({
            placement : 'right',
            trigger : 'hover',
            html : true,
        });
        $('[data-toggle="tooltip"]').tooltip({
            placement : 'left',
            trigger : 'hover',
            html : true,
        });
        $('[data-toggle="left-tooltip"]').tooltip({
            placement : 'left',
            trigger : 'hover',
            html : true,
        });
      }
    }






function hidePopovers() {
  $('[data-toggle="popover"]').popover('hide');
  $('[data-toggle="ajax-popover"]').popover('hide');
  $('[data-toggle="top-popover"]').popover('hide');
}

function hideTooltips() {
  $(".tooltip").tooltip("hide")
}


function viewMolStructure(id) {
     hidePopovers();
     hideTooltips();
     dataTables[id].columns(1).visible(false);
     dataTables[id].columns(2).visible(false);
     dataTables[id].columns(3).visible(true);
     dataTables[id].columns(4).visible(true);
     dataTables[id].draw(false);
   };

function viewMolNames(id) {
     hidePopovers();
     hideTooltips();
     dataTables[id].columns(1).visible(true);
     dataTables[id].columns(2).visible(true);
     dataTables[id].columns(3).visible(false);
     dataTables[id].columns(4).visible(false);
     dataTables[id].draw(false);
   };

function viewPartStructure(id) {
     hidePopovers();
     hideTooltips();
     dataTables[id].columns(5).visible(false);
     dataTables[id].columns(6).visible(false);
     dataTables[id].columns(7).visible(true);
     dataTables[id].columns(8).visible(true);
     dataTables[id].draw(false);
   };

function viewPartNames(id) {
     hidePopovers();
     hideTooltips();
     dataTables[id].columns(5).visible(true);
     dataTables[id].columns(6).visible(true);
     dataTables[id].columns(7).visible(false);
     dataTables[id].columns(8).visible(false);
     dataTables[id].draw(false);
   };

   window.alert = (function() {
     var nativeAlert = window.alert;
     return function(message) {
         window.alert = nativeAlert;
         message.indexOf("DataTables warning") === 0 ?
             console.warn(message) :
             nativeAlert(message);
     }
   })();
