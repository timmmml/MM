function ix = learning(FILE)

VS = FILE.choices(:,1);
RL = FILE.choices(:,3);
DL = FILE.choices(:,4);

% compute subjective value of LL option based on the other's discount rate
VL = RL ./ (1 + (10.^ FILE.k) * DL);

% Performance can either be set as the number of times the subject chose
% correctly as indicated by the feedback they received. But: choices
% for the other are noisy due to temperature parameter beta.
% ix = sum(FILE.subject_choice == FILE.model_choice)/length(FILE.subject_choice);

% Alternatively, performance can be compared to choices of an ideal, 
% noise-free other
ix = sum(FILE.subject_choice == (VL>VS)+1)/length(FILE.subject_choice);