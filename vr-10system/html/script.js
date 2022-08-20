var info;
var settings = {};
var show = true;
var currentPage = "settings";
$(".menu-container").hide()
$('#setting-page').hide()
$('#boss-page').hide()
$('#support-page').hide()
$(`#${currentPage}`).children().css('color', '#ef163a');
var UpdateColorsList = {}

document.onkeydown = (e) =>{
    const key = e.key;
    if (key == "Escape"){
        $('.menu-container').fadeOut()
        $.post("http://vr-10system/closeMenu",JSON.stringify({}));
    }
};

$(document).on("click","#close",function(){
    $('.menu-container').fadeOut()
    $.post("http://vr-10system/closeMenu",JSON.stringify({}));
})


$(document).on("click","#resetsettings",function(){
    
    $('#increase-size-font').val(`0.9rem`)
    $('#increase-size-opacity').val(`100`)
    settings.size = `0.9rem`
    settings.opacity = `100`
    $('.header').css('font-size', `0.9rem`);
    $('.players').css('font-size', `0.9rem`);
    $('.players me').css('font-size', `1rem`);
    $('.players me').css('font-weight', 'bold');
    $('.systyem-main').css('opacity', `100`);
    $(".systyem-main").css("left", "1%");
    $(".systyem-main").css("top", "3%");
    // left: 1 %;
    // top: 3 %;
})

function DragAble(){
    $( ".systyem-main" ).draggable({
        appendTo: 'body',
        containment: 'window',
        scroll: false,
    });
}

$(document).on("click","#savesettings",function(){
    let callsign = $('.callsign').val();
    if (callsign){
        $.post("http://vr-10system/saveChanges",JSON.stringify({
            callsign
        }));   
    }
})

$(document).on('input change', '#increase-size-font', function() {
    let fontSize = $('#increase-size-font').val();

    settings.size = fontSize / 10;
    
    $('.header').css('font-size', `${settings.size}rem`);
    $('.players me').css('font-size', `${Number(settings.size) + 0.1}rem`);
    $('.players').css('font-size', `${settings.size}rem`);
    $('.players me').css('font-weight','bold');
});

$(document).on('input change', '#increase-size-opacity', function() {
    let opacity = $('#increase-size-opacity').val();

    settings.opacity = opacity / 100

    $('.header').css('opacity', `${settings.opacity}`);
    $('.players me').css('opacity', `${settings.opacity}`);
    $('.players').css('opacity', `${settings.opacity}`);
    $('.systyem-main').css('opacity', `${settings.opacity}`);
});



$(document).on("click", ".sidebar-nav-text", function(){
    let parent = $(this).parent();
    let id = parent.attr('id');

    $(`#${currentPage}`).children().css('color', 'white');
    $(`#${currentPage}-page`).hide();

    currentPage = id;
    $(`#${currentPage}`).children().css('color', '#ef163a');
    $(`#${currentPage}-page`).show();

})

$(document).on("click", ".enable_list", function(){
    let toggled = $(this).children()[0].checked;
    $.post("http://vr-10system/toggleList", JSON.stringify({
        toggled
    }));
})


window.addEventListener('message', function(event){
    if(event.data.action == "open"){
        ShowList(event)
        $( ".systyem-main" ).slideDown()
    }else if(event.data.action == "close"){
        $( ".systyem-main" ).slideUp()
    }else if(event.data.action == "update"){
        ShowList(event)
    }else if(event.data.action == "menu"){
        GenerateColors(event.data.colorstags)
       $(".menu-container").fadeIn()
       if (event.data.isboss){
        $('#boss').show();
        $(".br-isboss").hide();
        $("#br-boss").show();

       }else{
        $("#br-boss").hide();
        $(".br-isboss").show();
        $('#boss').hide();
       }
       DragAble()
    }else if(event.data.action == "updatelist"){
        UpdateColorsList = event.data.tagstable
    }
})

$(document).on("click", "#addtags", function(){
    let html = ``
    $( "#addtags" ).remove();
    $('#savecallsigns').remove();
    html = `<input class="input" type="text" id="minsign" name="minsign" placeholder="MIN" style="margin-top: 18px; text-transform: uppercase;"><span> - </span><input class="input" type="text" id="maxsign" name="maxsign" placeholder="max" style="margin-top: 18px; text-transform: uppercase;"><span></span><input name="colorsign" type="color" value="#ff0000"><br>`
    $('#boss-page').append(html);
    html = `<button id="addtags" class="btn"><i class="fa fa-plus-square"></i></button>
            <button id="savecallsigns" class="btn"><i class="far fa-folder-open"></i> Save</button>
    `
    $('#boss-page').append(html);
})

$(document).on("click", ".deletebtn", function(){
    var Id = $(this).attr("id");
    document.getElementById(Id).remove();
    SaveNewCallSigns()
})

$(document).on("click", "#savecallsigns", function(){
    SaveCallSigns()
})

SaveCallSigns = () => {
    var minsign = document.getElementsByName("minsign");
    var maxsign = document.getElementsByName("maxsign");
    var colorsign = document.getElementsByName("colorsign");
    var tag = {}
    var alltags = []
    for(var i=0; i<minsign.length; i++) {
        tag = {
            min : minsign[i].value,
            max  :  maxsign[i].value,
            color : colorsign[i].value
        };
        alltags[alltags.length] = tag;
        tag = {}
    }
    $.post("http://vr-10system/saveTags", JSON.stringify({
        alltags
    }));
}

SaveNewCallSigns = () => {
    var minsign = document.getElementsByName("minsign");
    var maxsign = document.getElementsByName("maxsign");
    var colorsign = document.getElementsByName("colorsign");
    var tag = {}
    var alltags = []
    for(var i=0; i<minsign.length; i++) {
        tag = {
            min : minsign[i].value,
            max  :  maxsign[i].value,
            color : colorsign[i].value
        };
        alltags[alltags.length] = tag;
        tag = {}
    }
    $.post("http://vr-10system/saveNewTags", JSON.stringify({
        alltags
    }));
}

GenerateColors = (colorsTable) => {
    let html = ``
    $('#boss-page').html(`<label id="managecallsign">Manage Call Signs: </label><br>`);
    for(const tags in colorsTable){
        let deletetags = 'delete_'+tags
        let min = tags.split("-")[0]
        let max = tags.split("-")[1]
        html = `<div id="${deletetags}"> <input value="${min}" class="input" type="text" id="minsign" name="minsign" placeholder="MIN" style="margin-top: 18px; text-transform: uppercase;"><span> - </span><input value="${max}" class="input" type="text" id="maxsign" name="maxsign" placeholder="max" style="margin-top: 18px; text-transform: uppercase;"><span></span><input type="color" name="colorsign" value="${colorsTable[tags]}"><button id="${deletetags}" class="deletebtn"><i class="fa fa-trash-o"></i></button><br></div>`
        $('#boss-page').append(html);
    }
    html = `<button id="addtags" class="btn"><i class="fa fa-plus-square"></i></button>
            <button id="savecallsigns" class="btn"><i class="far fa-folder-open"></i> Save</button>
    `
    $('#boss-page').append(html);
}

GenerateColorsToList = (colorsTable, tag) => {
    for(const tags in colorsTable){
        let min = tags.split("-")[0]
        let max = tags.split("-")[1]
        if(tag >= Number(min) && tag <= Number(max)){
            return colorsTable[tags]
        }
    }
}

ShowList = (event) => {
    let arr = [];
    $('.systyem-container').html("");
    let players = event.data.data;
    let jobinfo = event.data.jobinfo
    $(".header-txt").html(`${jobinfo.label} Employee List`);
    if (event.data.sortby == "tag")
    {
        for(let key in players){
            arr[arr.length] = players[key];
            arr.sort((a, b) => a.code-b.code);
        }
    }else if(event.data.sortby == "job") 
    {
        for(let key in players){
            arr[arr.length] = players[key];
            arr.sort((a, b) => b.gradenumber-a.gradenumber);
        }
    }

    for(let i = 0; i < arr.length; i++){
        player = arr[i]
        $('.header-txt').text(`Active ${jobinfo.label} [ ${i + 1} ]`)
        if(player != null) {
            var html;
            var clr = player.talking ? "rgb(255, 0, 0)" : "rgb(255, 255, 255)";
            if (player.channel <= 0){
                player.channel = undefined
            }
            if (event.data.showjob){
                if (player.me){
                        html = `
                        <div class="players me">
                            <span class="tag" style="background-color: ${GenerateColorsToList(UpdateColorsList, player.code)}">${player.code}</span><span font-weight: bold;>${player.grade}</span> | ${player.name} - <span style="color: ${clr};" class="radioChannel">${player.channel != undefined ? player.channel + " Hz" : "OFF"}</span>
                        </div>`
                    $('.systyem-container').append(html);
                }else {
                        html = `
                        <div class="players">
                            <span class="tag" style="background-color: ${GenerateColorsToList(UpdateColorsList, player.code)}">${player.code}</span>${ player.grade } | ${player.name} - <span style="color: ${clr};" class="radioChannel" > ${ player.channel != undefined ? player.channel + " Hz": "OFF"}</span></span>
                        </div>`
                    $('.systyem-container').append(html);
                }
            }else{
                if (player.me){
                        html = `
                        <div class="players me">
                            <span class="tag" style="background-color: ${GenerateColorsToList(UpdateColorsList, player.code)}">${player.code}</span>${ player.name } - <span style="color: ${clr}; font-weight: bold;" class="radioChannel" > ${ player.channel != undefined ? player.channel + " Hz": "OFF"}</span></span>
                        </div>`
                    $('.systyem-container').append(html);
                }else {
                        html = `
                        <div class="players">
                            <span class="tag" style="background-color: ${GenerateColorsToList(UpdateColorsList, player.code)}">${player.code}</span>${ player.name } - <span style="color: ${clr}; font-weight: bold;" class="radioChannel" > ${ player.channel != undefined ? player.channel + " Hz": "OFF"}</span></span>
                        </div>`
                    $('.systyem-container').append(html);
                }
            }
            $('.players').css('font-size', `${settings.size}rem`);
            $('.systyem-main').css('opacity', `${settings.opacity}`);
        }
    }

}
