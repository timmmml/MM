// This script section will need to achieve automation of my task to reproduce what's written in Matlab. 
// Hopefully, I can add in some other degrees of control/visualization in addition to what's already there, aside from implementing the original code. 
export function Automatum(params){
    let { eta, kappa, beta, p } = params;
    this.p = params.p; 
    this.predict = function() {
        let z = 4 * p - 1; 
        let q = 1/(1 + Math.exp(-beta * z)); 
        let r = Math.random();
        if (r < q) {
            return 1;
        }else { 
            return 0;
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
