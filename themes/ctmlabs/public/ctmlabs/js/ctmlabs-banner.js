(function(){
    ctmlabs = {version:"0.0.1"};
    jQuery.noConflict();

    jQuery(document).ready(function(){
        var menuStr ='  <nav id="ctmlabs-nav" class="navbar navbar-fixed-top"> \
    <div class="navbar-inner"> \
      <div class="container"> \
        <!-- .btn-navbar is used as the toggle for collapsed navbar content --> \
        <a class="btn btn-navbar" data-target=".nav-collapse" data-toggle="collapse"> \
          <span class="icon-bar"></span> \
          <span class="icon-bar"></span> \
          <span class="icon-bar"></span> \
        </a> \
        <a class="ir brand" href="CTMLABSURL" id="ctmllink" title="CTMLabs home"></a> \
        <a href="APPURL" class="brand">APPNAME</a> \
        <div class="nav-collapse"> \
          <ul class="nav"> \
            <li class="dropdown"> \
              <a class="dropdown-toggle" data-toggle="dropdown" href="#"> \
                Applications\
                <b class="caret"></b> \
              </a> \
              <ul id="applications-list" class="dropdown-menu"> \
                 APPLIST \
              </ul> \
            </li> \
          </ul> \
          <ul class="nav pull-right"> \
            <li> \
              <a href="http://tracker.ctmlabs.net/projects/REDMINEPROJECT/issues/new" title="Report a problem with this website">Report Problem</a> \
            </li> \
            <li class="dropdown"> \
              <a class="dropdown-toggle" data-toggle="dropdown" href="#"> \
                Help\
                <b class="caret"></b> \
              </a> \
              <ul class="dropdown-menu"> \
                <li> \
                  <a href="APPHELP" title="Site help">Site Docs</a> \
                </li> \
                <li> \
                  <a href="APPCONTACT">Contact</a> \
                </li> \
              </ul> \
            </li> \
          </ul> \
        </div> \
      </div> \
    </div> \
  </nav> \
';
        jQuery("body").prepend(menuStr);
        jQuery("body").css('padding-top','40px');

        jQuery("#applications-list [title]").tooltip({placement:"right"});
        jQuery(".navbar-fixed-top [title]").tooltip({placement:"bottom"});
        /*
        jQuery.getJSON("CTMLABSURLjson/ctmlabs-apps.json", function(data) {
            jQuery.each(data.ctmlabs,function(index,item) {
                jQuery("#applications-list").append("<li><a href="+item.url+" title="+item.title+">"+item.label+"</a></li>");
            });

            jQuery(".container [title]").tooltip();
        }).error(function(jqXHR, textStatus, errorThrown) {
            alert( textStatus );
        });
        */
    });
        
})()

