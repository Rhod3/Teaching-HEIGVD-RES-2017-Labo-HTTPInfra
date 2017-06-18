$(function() {
    console.log("coucou");

    function getRoll100(){
        $.getJSON( "/api/students/", function(rollValue) {
            console.log(rollValue);
            msg = "You rolled " + rollValue.value;
            $(".intro-text").text(msg);
        });
    };
    getRoll100();
    setInterval(getRoll100, 2000);
});