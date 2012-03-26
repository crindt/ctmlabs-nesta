(function(){
    ctmlabs = {version:"0.0.1"};

    $(document).ready(function(){
        var menuStr ='  <nav id="ctmlabs-nav" class="navbar navbar-fixed-top"> \
    <div class="navbar-inner"> \
      <div class="container-fluid"> \
        <!-- .btn-navbar is used as the toggle for collapsed navbar content --> \
        <a class="btn btn-navbar" data-target=".nav-collapse" data-toggle="collapse"> \
          <span class="icon-bar"></span> \
          <span class="icon-bar"></span> \
          <span class="icon-bar"></span> \
        </a> \
        <a alt="CTMLabs" class="ir brand" href="http://wwwdev.ctmlabs.net/ctmlabs/" id="ctmllink" title="CTMLabs home"></a> \
        <div class="brand"> \
          CTMLabs\
        </div> \
        <div class="nav-collapse"> \
          <ul class="nav"> \
            <li class="dropdown"> \
              <a class="dropdown-toggle" data-toggle="dropdown" href="#"> \
                Applications\
                <b class="caret"></b> \
              </a> \
              <ul class="dropdown-menu"> \
                <li> \
                  <a href="https://tmcpe.ctmlabs.net/tmcpe-1.3">TMC Performance Evaulation</a> \
                </li> \
                <li> \
                  <a href="http://128.200.36.104:8080/SATMSWeb">Ramp Meter Evaluation Platform</a> \
                </li> \
                <li> \
                  <a href="http://moon.its.uci.edu/inside">INSIDE Laboratory</a> \
                </li> \
                <li> \
                  <a href="http://safety.ctmlabs.net/safetynet">Safety</a> \
                </li> \
              </ul> \
            </li> \
          </ul> \
          <ul class="nav pull-right"> \
            <li> \
              <a href="http://tracker.ctmlabs.net/projects/tb/issues/new" title="Report a problem with this website">Report Problem</a> \
            </li> \
            <li class="dropdown"> \
              <a class="dropdown-toggle" data-toggle="dropdown" href="#"> \
                Help\
                <b class="caret"></b> \
              </a> \
              <ul class="dropdown-menu"> \
                <li> \
                  <a href="http://wwwdev.ctmlabs.net/ctmlabs/help" title="Site help">Site Docs</a> \
                </li> \
                <li> \
                  <a href="http://wwwdev.ctmlabs.net/ctmlabs/about/people">Contact</a> \
                </li> \
              </ul> \
            </li> \
          </ul> \
        </div> \
      </div> \
    </div> \
  </nav> \
';
        $("body").prepend(menuStr);
        $("body").css('padding-top','60px');

        $(".navbar-fixed-top [title]").tooltip({placement:"bottom"});
        
    });
        
})()

