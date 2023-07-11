
// Probability Learning Task
//***************************************
//Copyright (c) Cauldron Science Ltd 2020
// THIS SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SCRIPT 
// OR THE USE OR OTHER DEALINGS IN THE SCRIPT.
//***************************************
//---------------
// SCRIPT DETAILS
//---------------
// This script decides if the trial is a win or lose trial based on a fixed probabilty. Depending on their response, participants are directed to 
// either a win or lose screen using an onScreenRedirect function. In the case of a win trial, participants' total score will increase.
// - using onScreenStartui
// - writing participants' responses to embedded data
// - using onScreenRedirect 
//---------------------------
// SCRIPT SPECIFIC DISCLAIMER
//---------------------------
// The potential hazards in using this script without proper care may include (but are not limited to the following...
// If the variables required for this process are not set up correctly, your embedded data might not be stored and the total score might not be accurate. 
// If the onScreenRedirect is not used correctly, the participants might not be directed to appropriate screens which might produce inaccurate results. 
// Make sure to understand the script fully and test it thoroughly, on different browsers, to avoid unwanted occurrences while running your experiment.
//------------------
// USER REQUIREMENTS
//------------------
// There are no special requirements to this script.
//-------------------
// REQUIRED VARIABLES
//-------------------
// These are the variables you would use and change:
// (Optional): Change the background colour to grey
var BACKGROUND_COLOUR = '#BFBFBF';

// Create a total score variable which is written to embedded data
var EMBEDDED_DATA_T = 'total_score'
var totalScore: number = gorilla.retrieve(EMBEDDED_DATA_T, 0, true); // it started at 0

// Create a 'win' score variable which is written to embedded data
var EMBEDDED_DATA_W = 'win_score'
var winScore: number = gorilla.retrieve(EMBEDDED_DATA_W, 0, true);

//-------------------
// MAIN SCRIPT
//-------------------
// Unless you want to change the functionality of the task, you shouldn't need to alter anything below this line.

gorillaTaskBuilder.onScreenStart((spreadsheet: any, rowIndex: number, screenIndex: number, row: any, container: string) => {
    $('body').css('background-color', BACKGROUND_COLOUR);
})
// use Gorillas onScreenRedirect function to get response and row values
gorillaTaskBuilder.onScreenRedirect((spreadsheet: any[], rowIndex: number, screenIndex: number, row: any, response: any, correct: boolean, timeOut: boolean, attempt: number) => {
    if(row.display == 'trial') { // you only want to apply this rule if the display is 'trial'
        if(screenIndex == 1) { // and the screen index is 1 i.e. offer screen
            if(response == 'greenBox.png') { // if they pressed the green button get the green value and prob from spreadsheet
                var prob: number = parseFloat(row.green_p); 
                var value: number = parseFloat(row.green_v);
            } else { // else get the blue value and prob from spreadsheet
                var prob: number = parseFloat(row.blue_p); 
                var value: number = parseFloat(row.blue_v);
            }
            
            var myrng = new Math.seedrandom(Date.now()); //Here we create a new random number list based on current date
            var randomNumber = myrng(); // and this is the random number variable

            if(randomNumber <= prob) { //if the random number is smaller than the probability you win
               totalScore += value; // the value of the slot machine is added to the total
// Call gorilla.store function in order to save participants' responses to embedded data that you could later use in your experiment
               gorilla.store(EMBEDDED_DATA_T, totalScore, true); // update the total score variable
               gorilla.store(EMBEDDED_DATA_W, value, true); // update the win score variable
               return {new_screenName: 'win'}; // go to the screen called win
            } else {
                return {new_screenName: 'lose'}; // otherwise go to the screen called lose
            }
            
        }
    }
})
// Add image content to screen dynamically

//***************************************
//Copyright (c) Cauldron Science Ltd 2017
// THIS SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SCRIPT 
// OR THE USE OR OTHER DEALINGS IN THE SCRIPT.
//***************************************
//---------------
// SCRIPT DETAILS
//---------------
// In this script we will use the onScreenStart hook, the 'Recent Answer' embedded data
// and the screen zone name to dynamically populate the screen with the most recent answer
// We will use this to display the previously selected, incorrect answer to a trial

// In onScreenStart, we will check to see if we are on the 'incorrect' screen.
// If we are, we will collect the most recent answer from embedded data.
// Next, we will create the url to that stimuli using gorilla.stimuliURL.
// Finally, use a screen zone name as a selector, we will dynamically add the image to the screen

//  This code demonstrates
// - using onScreenStart
// - using gorilla.retrieve to collect embedded data
// - using gorilla.stimuliURL to create the url to a stimuli
// - using a screen zone name as a jQuery selector

//---------------------------
// SCRIPT SPECIFIC DISCLAIMER
//---------------------------
// The potential hazards in using this script without proper care may include (but are not limited to) those explained below...
// 
// Gorilla prepopulates several trials in advance, loading trial content in the background so it can be displayed
// seamlessly to the participant.  Dynamically adding content to the screen using script circumvents this process entirely
// As a result, content may not display seamlessly and there may be a noticable, sudden appearences of the new content.
// In this example, as the image to be displayed is one from a previous screen, the image should be cached in the browser
// memory and be quick to load.  However, if it is a new stimuli, if the content is large in size or if the participants browser
// is operating at diminshed performance, there may be a noticeable interruption in presentation.
//
// Make sure to test the task thoroughly and insure that any interruptions to the display are acceptable for your task

//------------------
// USER REQUIREMENTS
//------------------
// For this script to function correctly you will need to
// 1) Change the value of _requiredDisplay to match the display name for the trials where the image needs to be added
// 2) Change the value of _requiredScreen to match the screen number where the image needs to be added
// 3) Change the value of _requiredZoneName to match the name of the zone where the content needs to be displayed
// 4) Change the value of _recentAnswerKey to match the string used for the 'Recent Answer' embedded data setting


//-------------------
// REQUIRED VARIABLES
//-------------------
// These are the variable you may want to change

// This variable indicates the display name for trials where we want to add the image content
var _requiredDisplay: string = 'task';

// This variable indicates the screen number for the screen requiring the image content
// This numbering starts at 0 for the 1st screen, 1 for the 2nd screen etc.
var _requiredScreen: number = 3;

// This variable indicates the name of the zone where we want to add the image content
// To access and edit this name go to the screen where the zone is present, click 'Edit Layout'
// and then click on the desired zone.  You will then see the Zone Name field.
var _requiredZoneName: string = 'incorrectAnswer';

// Embedded data strings
// This is the key used for storing the most recent answer in embedded data
var _recentKey = 'recent';

// ------ //
// If you structure your task in a similar manner to the example task, you won't need to edit anything below this line

// This hook allows us to create custom functionality to run when a screen starts
gorillaTaskBuilder.onScreenStart((spreadsheet: any, rowIndex: number, screenIndex: number, row: any, container: string) => {
    // We need to check if we are on the screen display
    if(_requiredDisplay && row.display == _requiredDisplay){
        // Next, we need to check if we are on the correct screen
        if((_requiredScreen || _requiredScreen == 0) && screenIndex == _requiredScreen){
            // Now that we are on the correct display and screen, we need to collect the most recent answer
            var recentAnswer: string = gorilla.retrieve(_recentKey, null, true);
            
            if(recentAnswer){ // it's always good practice to make sure that the retrieved variable does exist!
                // Next, we need to create the URL for that stimuli
                var stimuliURL: string = gorilla.stimuliURL(recentAnswer);
                
                // Now, we need to find our existing image element, using the required zone name, and change its source
                // to be the new stimuli we want to display
                // The src attribute sets where the image element gets its content from
                // Behind the scenes, when you give a Gorilla Image zone a stimuli, we find the URL to this stimuli and then
                // set the src of the image zone to be that URL - essentially, the same process carried out in this script!
                // Changing the src attribute in this way will automatically cause the image zone to display the new image
                $(container + ' .' + _requiredZoneName).attr('src', stimuliURL);
               
                // For good measure, we're going to refresh the screen layout, just incase adding our image has disrupted
                // the screen
                gorilla.refreshLayout();
                
                
            } else {
                alert('Recent answer could not be retrieved');
            }
            
        }
    }
    
});

