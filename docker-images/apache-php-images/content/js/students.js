$(function() {
    console.log("coucou");

    function loadStudents(){
        $.getJSON( "/api/students/", function(students) {
            console.log(students);
            var msg = "Nobody";
            if ( students.length > 0 ) {
                msg = students[0].firstname + " " + students[0].lastName;
            }
            $(".skills").text(msg);
        });
    };
    loadStudents();
    setInterval(loadStudents, 2000);
});