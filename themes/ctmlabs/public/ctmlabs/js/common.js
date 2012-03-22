(function(){
    ctmlabs = {version:"0.0.1"};

    $(document).ready(function(){
        $(".container [title]").tooltip();

        //$("#slider").nivoSlider({effect:'fade'});
        $("#slides").slides({responsive:true,startAtSlide:1,
                             effect:'fade',
                             navigation: false,
                             pagination: false,
                             effects:{navigation:'fade',
                                      pagination:'fade'}
                            });
        setTimeout(function(){ $("#slides").slides("play"); }, 1000);
        
    });
        
})()

