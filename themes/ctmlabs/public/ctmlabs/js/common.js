(function(){
    ctmlabs = {version:"0.0.1"};

    // from: http://www.javascriptkit.com/javatutors/loadjavascriptcss.shtml
    function loadjscssfile(filename, filetype){
        if (filetype=="js"){ //if filename is a external JavaScript file
            var fileref=document.createElement('script')
            fileref.setAttribute("type","text/javascript")
            fileref.setAttribute("src", filename)
        }
        else if (filetype=="css"){ //if filename is an external CSS file
            var fileref=document.createElement("link")
            fileref.setAttribute("rel", "stylesheet")
            fileref.setAttribute("type", "text/css")
            fileref.setAttribute("href", filename)
        }
        if (typeof fileref!="undefined")
            document.getElementsByTagName("head")[0].appendChild(fileref)
    }

    ctmlabs.banner = function() {
        // Find nav element
        var head = d3.select('#ctmlabsheader');
        if ( head ) {
            // found element, load css
            //loadjscssfile("http://api.ctmlabs.net/ctmlabs/css/ctmlabs-banner.css","css");
            loadjscssfile("ctmlabs-banner/ctmlabs-banner.css","css");

            head.selectAll("*").remove();  // remove children

            // create menu block
            var ctmlabsnav = head.append('nav').attr("class","ctmlabs");
            var navdata = [
                { "nest": "Home", "label": "&nbsp;", "class": "home", "title": "CTMLabs home", "url": "http://www.ctmlabs.net" },
                { "nest": "Project Websites", "label": "Project Websites", "url": "http://www.ctmlabs.net/projects" },
                { "nest": "Project Websites", "label": "TMC Performance Evaluation", "url": "https://tmcpe.ctmlabs.net" },
                { "nest": "Project Websites", "label": "Ramp Meter Evaluation Platform", "url": "https://128.200.36.104:8080/SATMSWeb" },
                { "nest": "Project Websites", "label": "INSIDE Laboratory", "url": "http://moon.its.uci.edu/inside" },
                { "nest": "Project Websites", "label": "Safety", "url": "http://safety.ctmlabs.net/" },
                { "nest": "Project Websites", "label": "CalVAD", "url": "http://lysithia.its.uci.edu/map7" },
                { "nest": "Issue Tracker", "label": "Issue Tracker", "url": "http://tracker.ctmlabs.net/" }
            ];
            var datanest = d3.nest()
                .key(function(d) { 
                    return d.nest; } )
                .map(navdata);
            var ee = d3.entries(datanest);
            var l1 = ctmlabsnav.append("ul").selectAll("li")
                .data(ee)
                .enter().append("li")
            l1.append("a")
                .attr("class",function(d){ return d.value[0].class })
                .attr("title", function(d) { 
                    return d.value[0].title ? d.value[0].title : d.value[0].label; } )
                .attr("href", function(d) { return d.value[0].url; })
                .html(function(d) { return d.value[0].label; } );

            l1.append("ul")
                .selectAll("li")
                .data(function(d) { return d.value.slice(1); // first element is menu title
                                  } )
                .enter().append("li").append("a")
                .attr("title", function(d) { 
                    return d.title ? d.title : d.label; } )
                .attr("href", function(d) { return d.url; })
                .html(function(d) { return d.label; });

            var accountdata = [];
            var service = document.location.protocol +
                "//"+document.location.host+"/"
            if ( casdata != null && casdata.username != null ) {
                accountdata.push(
                    { "nest": "account", "label": casdata.username, "title": "Logged in as " + casdata.username } );
                accountdata.push(
                    { "nest": "account", "label": "Manage", "title": "Manage your CTMLabs account", "url": "http://www.ctmlabs.net/account/manage" });
                accountdata.push(
                    { "nest": "account", "label": "Log out", "title": "Log out of CTMLabs", "url": "http://localhost:9393/logout?service="+service });
            } else {
                accountdata.push(
                    { "nest": "account", "label": "Log in", "title": "Log in to CTMLabs", "url": "https://cas.ctmlabs.net/cas/login?service="+service } );
            }
            accountdata.push(
                { "nest": "problem", "label": "Report Problem", "title": "Report a problem with this website", "url": "http://tracker.ctmlabs.net/projects/tb/issues/new" } );
            accountdata.push(
                { "nest": "about", "label": "About", "title": "About CTMLabs", "url": "http://www.ctmlabs.net/about" });
            var datanest = d3.nest()
                .key(function(d) { 
                    return d.nest; } )
                .map(accountdata);
            var accountnav = head.append('nav').attr("class","account");
            var ee = d3.entries(datanest);
            var l1 = accountnav.append("ul").selectAll("li")
                .data(ee)
                .enter().append("li")
            l1.append("a")
                .attr("class",function(d){ return d.value[0].class })
                .attr("title", function(d) { 
                    return d.value[0].title ? d.value[0].title : d.value[0].label; } )
                .attr("href", function(d) { return d.value[0].url; })
                .html(function(d) { return d.value[0].label; } );

            l1.append("ul")
                .selectAll("li")
                .data(function(d) { return d.value.slice(1); // first element is menu title
                                  } )
                .enter().append("li").append("a")
                .attr("title", function(d) { 
                    return d.title ? d.title : d.label; } )
                .attr("href", function(d) { return d.url; })
                .html(function(d) { return d.label; });


        }
    }

    window.onload = function(){
        ctmlabs.banner();
    };
    ctmlabs.banner();
        
})()

