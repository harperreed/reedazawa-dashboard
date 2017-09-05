var socket = io('//'+document.location.hostname+':'+document.location.port);

socket.on('weather', function (data) {
  if ($('#weather #temperature').text()==data.temp_f){
    console.log("don't change temp")
  }else{
    console.log("change temp")
    $('#weather #temperature').text(data.temp_f);
  }
  console.log($('#weather #icon').src)
  if ($("#weather #icon").attr("src")==data.icon_url){
    console.log("don't change icon")
  }else{
    console.log("change icon")
    $("#weather #icon").attr("src",data.icon_url);
    
  }
  console.log(data.icon_url);
});


socket.on('quotation', function (data) {
  $('#quotation #quote').text(data.quotation);
  $('#quotation #author').text(data.author);
});

socket.on('presence', function (presence) {
  console.log(presence)
  if (presence.everyone_home){
    $("#everyone_home").show();
    $("#people_away").hide();
    $("#people_away_title").hide();
  }else{
    $("#everyone_home").hide();
    $("#people_away").show();
    $("#people_away_title").show();
    $("#people_away").removeAttr( 'style' );
    $("#people_away_title").removeAttr( 'style' );
  }
  console.log(presence.people)

  if (!presence.everyone_home){
    maps = []
    presence.people.forEach(function(person){
      console.log(person);
      person.name = person.full_name.split(" ")[0]
      if (!person.present) {
        console.log(person.name +" away")
        //img.figure-img.img-fluid.rounded(src=people.location.map_url, alt=people.full_name)
        caption_text = ""
        if (person.location.inTransit>0){
          speed = Math.round(person.location.speed)
          caption_text = person.name + ' is in transit ('+speed+' mph)';
        }else if (person.location.name != undefined){
          caption_text = person.name + ' is at ' + person.location.name;
        }else{
          caption_text = person.name + ' is at ' + person.location.address1 + ', ' + person.location.address2;
        }


        html = [
          '<div class="col"><figure class="figure">',
          '   <img src="'+person.location.map_url+'" class="figure-img img-fluid rounded" alt="'+caption_text+'">',
        ]
        

        html.push('<figcaption class="figure-caption text-center"><p>'+caption_text+'</p></figcaption>')  
        html.push('</figure></div>') 
        


        html = $(html.join("\n"));
        maps.push(html)


      }else{
        console.log(person.name +" present")
      }
    })
    console.log(maps)

    $("#people_away").html(maps)
  }

});
