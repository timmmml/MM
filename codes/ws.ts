function Automatum(params){
    let { eta, kappa, beta, p } = params;
    this.p = params.p; 
    this.predict = function() {
        let z = 4 * p - 1; 
        let q = 1/(1 + Math.exp(-beta * z)); 
        let r = Math.random();
        if (r < q) {
            return 0;
        }else { 
            return 1;
        }
    } 
    this.update = function(subjChoice) {
        // Note that subjChoice is 0 or 1. (0 = shirk, 1 = work)
        // (DONT READ: now obsolete) choice denotes whether this automata is to update with the second-order rule. 
        //choice = 1 means yes, choice !=1 means no.
        let d1 = subjChoice - p; 
        let qq = 0;
        if (p == 0){
            qq = 1;
        } else if (p == 1) {
            qq = 0; 
        } else { 
            qq = 1/2 + Math.log((1-p)/p)/(4 * beta);
            if (qq > 1) { 
                qq = 1;
            }
            if (qq < 0) {
                qq = 0;
            } 
        } 
        let d2 = subjChoice - qq; 
        this.p = p + eta * d1 - kappa * d2; 
    }

}
var sIndex = 0;
var correctnessKey = 'correct'; 
var plistKey = 'plist';
var answerKey = 'ans';
var confidenceKey = 'conf';
var totalScores = 'scores';
var score_per = 50;
gorillaTaskBuilder.preProcessSpreadsheet(
(spreadsheet: any) => {
    gorilla.store(plistKey, [0.5], true);
    gorilla.store(answerKey, [], true);
    gorilla.store(totalScores, 0, true); 
    return spreadsheet;
});
gorillaTaskBuilder.isCorrect((spreadsheet: any, rowIndex: number, screenIndex: number, row: any, response: string, zoneName: string, zoneType: string) => {
    if (row.display == 'trials') { 
        if (screenIndex == sIndex){
            var resp = parseInt(response);
            var pList = gorilla.retrieve(plistKey, '', true);
            //alert(response)
            var params = {
                eta: 0.3, 
                kappa: 0.1, 
                beta: 1.5,
                p: pList[pList.length-1]
            }
            var automata = new Automatum(params);
            var automataChoice = automata.predict();
            automata.update(resp);
            var ans = 1 - automataChoice; 
            var anslist = gorilla.retrieve(answerKey, '', true)
            if (rowIndex < spreadsheet.length-1) { 
                pList.push(automata.p);
                anslist.push(ans);
                gorilla.store(answerKey, anslist, true);
                gorilla.store(plistKey, pList, true);
            }
            var sate: boolean = (resp != ans)
            gorilla.store(correctnessKey, sate, true);
            if (resp == row['work']){
                return{newCorrect: true;}
            }else {
                return{newCorrect: false;}
            }
        } else if (screenIndex == sIndex + 1 || screenIndex == sIndex + 2){
            return {newCorrect: true;} 

        }
    } return null; 
});
var worked = 'work selected';
var shirked = 'shirk selected';
var workCorrect = 'work correct';
var workIncorrect = 'work incorrect';
var shirkCorrect = 'shirk correct';
var shirkIncorrect = 'shirk incorrect';
var start = 'trial screen';
gorillaTaskBuilder.onScreenRedirect((spreadsheet: any[], rowIndex: number, screenIndex: number, row: any, response: any, correct: boolean, timeOut: boolean, attempt: number) => {
    if (row.display == 'trials') { 
        if (screenIndex == sIndex){
            if (correct){
                return {new_screenName: worked, new_rowIndex: 0, rowIndexRelative: true;}
            } else {
                return {new_screenName: shirked, new_rowIndex: 0, rowIndexRelative: true;}
            }
        } else if (screenIndex == sIndex +1 || screenIndex == sIndex+2){
            var correctness: boolean = gorilla.retrieve(correctnessKey, '', true);
            if (correctness) {
                if (screenIndex == sIndex + 1) { 
                    return {new_screenName: workCorrect, new_rowIndex: 0, rowIndexRelative: true;}
                } else {
                    return {new_screenName: shirkCorrect, new_rowIndex: 0, rowIndexRelative: true;}
                }
            } else {
                if (screenIndex == sIndex + 1) {
                    return {new_screenName: workIncorrect, new_rowIndex: 0, rowIndexRelative: true;}
                } else {
                    return {new_screenName: shirkIncorrect, new_rowIndex: 0, rowIndexRelative: true;}
                }
            }
        } else if (screenIndex != 0){ 
            if (rowIndex<spreadsheet.length-1){
                return {new_screenName: start, new_rowIndex: 1, rowIndexRelative: true;}
            }
        }
    } return null;
});

gorillaTaskBuilder.onScreenFinish((spreadsheet: any, rowIndex: number, screenIndex: number, row: any, container: string, correct: boolean) => {
    if (row.display == 'trials') { 
        var indlist: any[] = [sIndex+3, sIndex + 4, sIndex + 5, sIndex + 6]
        if (indlist.includes(screenIndex)){
            var correct_attempt = gorilla.retrieve(correctnessKey, '', true);
            var score = gorilla.retrieve(totalScores, 0, true);
            var y = gorilla.retrieve(plistKey, 0, true);
            gorilla.metric({
                x_coord: correct_attempt * score_per + score,
                y_coord: y[y.length - 1]
            })
            gorilla.store(totalScores, correct_attempt * score_per + score, true);
        }
    } return null;
});