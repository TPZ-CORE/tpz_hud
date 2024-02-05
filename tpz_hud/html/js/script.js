
const DEFAULT_ELEMENTS_LIST = [
    'varHunger', 
    'varThirst', 
    'varMic', 
    'varTemp',
]

const LEVELING_ELEMENTS_LIST = [
    'varHunting', 
    'varFarming', 
    'varMining',
    'varLumberjacking', 
    'varFishing',
]

window.onload = function() {
    this.document.getElementById("main").style.display = "none";

    LEVELING_ELEMENTS_LIST.forEach((element) => { 
        $("#" + element).hide();
    });
}

window.addEventListener('message', function (event) {

    if (event.data.action == "DISPLAY_HUD") {
        var hud = this.document.getElementById("main");

        hud.style.display = event.data.display === false ? "none" : "block";
    }

	if (event.data.action == 'SET_LEVELING_DISPLAY_STATUS') {

        LEVELING_ELEMENTS_LIST.forEach((element) => { 
            event.data.status === true ? $("#" + element).show() : $("#" + element).hide();
        });


    } else if (event.data.action == 'SET_HUD_DISPLAY_STATUS') {

        // Minimap Circular Background Image.
        event.data.status ? $('minimapImageDisplay').show() : $('minimapImageDisplay').hide();

        // Default HUD Elements.
        DEFAULT_ELEMENTS_LIST.forEach((element) => { 
            event.data.status ? $("#" + element).show() : $("#" + element).hide();
        });

        // Leveling HUD Elements.
        if (event.data.hasLeveling){

            LEVELING_ELEMENTS_LIST.forEach((element) => { 
                event.data.status ? $("#" + element).show() : $("#" + element).hide();
            });
            
        }

        if (event.data.hasAlcohol) {
            event.data.status ? $('#varAlcohol').show() : $('#varAlcohol').hide();
            
            if (!event.data.hasStress) {
                $('#varAlcohol').css('left', '25%');
            }

        }else{
            $('#varAlcohol').hide();
        }
        

        if (event.data.hasDirtSystem) {
            event.data.status ? $('#varDirt').show() : $('#varDirt').hide();

            if (!event.data.hasStress) {
                $('#varDirt').css('left', '28.5%');
            }
            
        }else{
            $('#varDirt').hide();
        }

        if (event.data.hasStress) {
            event.data.status ? $('#varStress').show() : $('#varStress').hide();
            
        }else{
            $('#varStress').hide();
        }


    } else if (event.data.action == 'UPDATE_VOICE_TALK_STATUS') {

        $("#varMic small").text(event.data.isTalking ? " 🔊" : "🔇");

    } else if (event.data.action == 'UPDATE_HUD_STATUS') {


        if(event.data.temp) { 
            $("#varTemp small").text(" ‍" + event.data.temp);
            document.getElementById('varTemp').style.backgroundColor = event.data.tempColor;
        }

        if(event.data.cash) {
            $("#varMoney small").text(event.data.cash.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
        }

        if(event.data.hunger) {
            $("#varHunger").attr("class", "c100 p"+ Math.ceil(event.data.hunger));
            setColouredBasedOnValue("varHunger", event.data.hunger);
        }
        
        if(event.data.thirst) {
            $("#varThirst").attr("class", "c100 p"+ Math.ceil(event.data.thirst));
           setColouredBasedOnValue("varThirst", event.data.thirst);
        }

        if(event.data.stress) {
            let stress = event.data.stress;

            stress = (stress == null || stress == 0) ? -1 : stress;

            $("#varStress").attr("class", "c100 p"+ stress);

            $("#varStress").css("background-color", stress >= 85 ? "#750c0ca" : "#161616a8");
        }

        
        if(event.data.alcohol) {
            let alcohol = event.data.alcohol;

            alcohol = (alcohol == null || alcohol == 0) ? -1 : alcohol;

            $("#varAlcohol").attr("class", "c100 p"+ alcohol);

            $("#varAlcohol").css("background-color", alcohol >= 85 ? "#750c0ca" : "#161616a8");
        }

        if (event.data.dirt) {
            
            $("#varDirt").attr("class", "c100 p"+ Math.ceil(event.data.dirt));
            setColouredBasedOnValue("varDirt", event.data.dirt);
        }


        if (event.data.hunting) {
            $("#varHunting small").text(Math.ceil(event.data.hunting.level));
            $("#varHunting").attr("class", "c100 small first p"+ event.data.hunting.experience);
        }

        if (event.data.farming) {
            $("#varFarming small").text(Math.ceil(event.data.farming.level));
            $("#varFarming").attr("class", "c100 small first p"+ event.data.farming.experience);
        }

        if (event.data.mining) {
            $("#varMining small").text(Math.ceil(event.data.mining.level));
            $("#varMining").attr("class", "c100 small first p"+ event.data.mining.experience);
        }

        if (event.data.lumberjacking) {
            $("#varLumberjacking small").text(Math.ceil(event.data.lumberjacking.level));
            $("#varLumberjacking").attr("class", "c100 small first p"+ event.data.lumberjacking.experience);
        }

        if (event.data.fishing) {
            $("#varFishing small").text(Math.ceil(event.data.fishing.level));
            $("#varFishing").attr("class", "c100 small first p"+ event.data.fishing.experience);
        }
    
    }

    function setColouredBasedOnValue(elementId, value) {

        if (value == -1 || value <= 0 || elementId == "varDirt" && value <= 25 || elementId == "varStress" && value <= 25) {
            document.getElementById(elementId).style.backgroundColor = "#750c0ca8";

        }else{
            document.getElementById(elementId).style.backgroundColor = "#161616a8";
        }
    }


});
