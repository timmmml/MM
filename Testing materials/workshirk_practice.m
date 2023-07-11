clear;
close;
addpath cogent2000v1.32\Toolbox
%---------------------------------------------------------------------------%
% Programmed by Christopher Hill, SNS lab, christoph.hill0@gmail.com
% Updated on 6/11/2013
% Updated on 1/07/2016 updated 
% On the waiting screen : press key 5 to to start the experiment (top row)
%---------------------------------------------------------------------------%

S_ID = str2double(input('Please enter SUBJECT number # > ', 's'));

%----------------------------------------------------%
% CONFIGURE EMPLOYER                       %
% Parameters, prior beliefs                          % 
%----------------------------------------------------%

% choices Employee: 1 for 'work'; 0 for 'shrink'
% choices Employer: 1 for 'not inspect'; 0 for 'inspect'
% open question : implement "empirical" payoff sensitivity? 

% employee's parameters 
%--------------------------------------------------------------------------
% IMPORTANT NOTE : these are mock parameters to get a feeling for how the
% algorithm behaves. The (inverse) temperature and the parameters a high for
% demonstration purposes. 
%--------------------------------------------------------------------------

eta_yer = 0.3; %Governs how likely the algorithm will match your previous choice. (First-order learning rate)
kappa_yer = 0.1; %Governs how likely the algorithm will switch to counteract your learning. (Influence parameter)
beta_yer = 1.5; %Governs the fidelity of how beliefs are transformed into choices. (Inverse temperature) 

% preparation of variables
p = 0.5; %Employer's prior (naive) beliefs about the odds of WORK

%----------------------------------------------------%
% CONFIGURE EXPERIMENTAL PARAMETERS                  %
% images, payoff matrix, onsets, keys, screens, etc. % 
%----------------------------------------------------%

tic 
% TIMING PARAMETERS 
% First column : onsets of choice
% Second column : onsets of feedback 


Time_for_choice = 4000; % alloted choice maximun response time 
Time_confirmation_square = 2000; % Duration of the confirmation square presentation
Time_feedback_presentation = 3000; % Duration of feedback presentation

% EXPERIMENTAL PARAMETERS %% 
Run_number = 1;    
Num_trials = 10; %from 1 to 80 trials   

% Payoff structure for the Player
HighVal = 50;
LowVal = 50;
sPayoff = [0 LowVal; HighVal 0];     
sImage_names = cellstr(strvcat('shirk.bmp','work.bmp'));
sImage_names_light = cellstr(strvcat('shirk_light.bmp','work_light.bmp'));

% CONFIGURE COGENT %%
config_keyboard(100,5,'exclusive');
%config_display(1,3,[0.7059 0.7059 0.7059],[.2 .2 .9], 'Arial', 25, 10);
config_display(1,1,[0.7059 0.7059 0.7059],[.2 .2 .9], 'Arial', 25, 11); %TV: added custom screen size in this function to make it work on Win11 (set "resolution" variable to 1 to index correctly)

% SGM 
%  config_serial(1,19200);

config_log('Scanner_Player.log');

ChoicePic = 1;
WorkInspectPic = 2;
WorkNoInspectPic = 3;
ShirkInspectPic = 4;
ShirkNoInspectPic = 5;
NeutralPic = 6;
NullPic = 7;
FareWellPic = 8;
StartScreen = 9;
InstructScreen=10;

% Updated on 19/10/2013
ResultPic(1,1) = ShirkInspectPic;
ResultPic(1,2) = ShirkNoInspectPic;
ResultPic(2,1) = WorkInspectPic;
ResultPic(2,2) = WorkNoInspectPic;

pic1=loadpict(sImage_names{1});
pic2=loadpict(sImage_names{2});
pic1_light=loadpict(sImage_names_light{1});
pic2_light=loadpict(sImage_names_light{2});
null_pic=loadpict('null_event.bmp');
text_blank=loadpict('blank_text.bmp');

% Pre-allocation 
s_answer=zeros(1,Num_trials);                % player-s answer
s_answer_opp = zeros(1,Num_trials);          % opponents answer
s_reward=zeros(1,Num_trials);                % value of reward recieved

% START COGENT 
start_exp_to_cogent = toc;
start_cogent;
tic

%keys % CHANGED 24/08/2013
keymap = getkeymap;
MRIsig = [32 62];  %5 or '
space_bar = 71;
cmd_exit = 3;       %CTRL-C
key_exit = 17; % ESCAPE (SGM)
key_left = 97;
key_right = 98;

%Image preparation
%Put a cross in the middle of all screens
setforecolour(0,0,0);
settextstyle('Arial',60);
preparestring('+',ChoicePic,0,-6);
preparestring('.',NeutralPic,0,7);
settextstyle('Arial',30);
preparestring('The PRACTICE',StartScreen,0,30);
preparestring('is about to start.',StartScreen,0,0);
preparestring('Good luck!',StartScreen,0,-30);
preparestring('Welcome',InstructScreen,0,30);
preparestring('Please wait for',InstructScreen,0,0);
preparestring('instructions. Thanks!',InstructScreen,0,-30);
preparepict(null_pic,NullPic,0,0);
preparepict(loadpict('work_inspect.bmp'),WorkInspectPic,0,-45);
preparepict(loadpict('work_noinspect.bmp'),WorkNoInspectPic,0,-45);
preparepict(loadpict('shirk_inspect.bmp'),ShirkInspectPic,0,-45);
preparepict(loadpict('shirk_noinspect.bmp'),ShirkNoInspectPic,0,-45);


%----------------------------------------------------------%
% EXPERIMENTAL PART - START SCREEN                         %
% Press key 5 to begin                                     %
% Will begin cycling through the trials                    %
%----------------------------------------------------------%

drawpict(StartScreen);

% Wait for scanner trigger. If training - use key ''5'' 
waitkeydown(inf,MRIsig);
Subject.FMRI_start_byte_resp = time;

logstring('Experiment Started');
Subject.Onset_fmri = time; 

%Draw neutral pic
drawpict(NeutralPic);

% Get experiment start time. 
virtual_cogent_start = toc;
Subject.Onset_virtual_cogent = virtual_cogent_start;

% DEFINE ONSET VALUES
%Take into account the true time of the experiment start
%Transform mat to milliseconds
%Solves the asynchronous cogent_start issue

%SGM
if 0 % USE ORIGINAL? 
   load('Onsets')
   Event_onsets = (Onsets(:,:,Run_number+1,S_ID)+virtual_cogent_start)*1000; 
else
    % two event columns - 8 and 3 at the moment, in seconds. 80 trial
    Onsets = bsxfun(@plus, [2,8], [0:Num_trials-1]'*9 );
    % should give
    %    3   5
    %   12  14
    %   21  23
    Event_onsets = (Onsets + virtual_cogent_start) * 1000;
end

% EXPERIMENT PART - CYCLE TRIALS
%--------------------------------%

for i = 1:Num_trials
    
    %---------------------%
    % DISPLAY CHOICE PICS %
    %---------------------%
    
    % Prepare choice options
    preparepict(pic1,ChoicePic,-145,0); %on left
    preparepict(pic2,ChoicePic,145,0);  %on right
    
    % TIMING 1 Wait for the choice event to occur
    waituntil(Event_onsets(i,1))

    %clear the key buffer
    readkeys;
    logkeys;
    clearkeys; 

    Choice_presentation = drawpict(ChoicePic);
    logstring('Choice cue presented');
    
    %------------------------------------%
    % REGISTER THE CHOICE OF THE SUBJECT %
    %------------------------------------%
    
    % SAVE : Onsets of choice screen
    Subject.Onsets_choice_screen(i) = Choice_presentation-Subject.FMRI_start_byte_resp; 
    % TIMING 2 : Display choice for 2 seconds
    % Register key press, show confirmation squares. 
    % SAVE 2 : RT of subject
    [key, choice_answer_time, num_pressed] = waitkeydown(Time_for_choice,[key_left key_right key_exit]);

    if num_pressed == 0
        %no key was pressed
        logstring('key press timed out...');
        drawpict(NeutralPic);
        choice_answer_time = Event_onsets(i,1) + Time_for_choice;
        Subject.Onsets_response(i) = -99;
        s_answer(i) = 0;
    else
        choice_answer_time = choice_answer_time(1); %sometimes, more than one keypress can go through (Cogent Bug), so just keep the first.
        if key(1) == key_left
            logstring('Choice A');
            preparepict(pic1_light,ChoicePic,-145,0);
            drawpict(ChoicePic);
            Subject.Onsets_response(i) = choice_answer_time-Subject.FMRI_start_byte_resp;
            s_answer(i) = 1;
        elseif key(1) == key_right
            choice_answer_time = choice_answer_time(1);
            logstring('Choice B');
            preparepict(pic2_light,ChoicePic,145,0);
            drawpict(ChoicePic);
            Subject.Onsets_response(i) = choice_answer_time-Subject.FMRI_start_byte_resp;
            s_answer(i) = 2;
        elseif key(1)== key_exit % SGM
            break;
        else
            %I was not looking for this key to be pressed.... check for bugs?
            logstring('Wrong key was pressed');
            Subject.Onsets_response(i) = -98;
            s_answer(i) = 0;
        end
    end
 
    % SAVE 3 : Answer of subject
    Subject.response = s_answer;
    
    % TIMING 3 : Display the confirmation square for 750 MS
    waituntil(min(choice_answer_time + Time_confirmation_square, Event_onsets(i,1) + Time_for_choice));
    drawpict(NeutralPic);
    logstring('End of choice screen');
    
    %------------------------------------------------------%
    % ALGORITHM MAKES HIS CHOICE BASED ON CURRENT BELIEFS  %            
    %------------------------------------------------------% 
    
    %recall p is the current estimate of the algorithm that the player will
    %WORK.
    
    %It needs to be turned into q, the probability for the employer to
    %inspect. 
    
    %p is then integrated with the Employer's payoff matrix to become z. 
    z = 4 * p - 1; %Option WORK/NOT INSPECT is 4x more profitable. 
    
    %z is then fed into a softmax to determine q 
    q = 1 / (1 + exp(-beta_yer * z));
    
    %we store q for reference
    Subject.Algorithm.p_Not_Inspect(i) = q; 
    
    %Lets roll the dice with q.
    % make a choice
    if rand() < q
        s_answer_opp(i) = 2;
    else
        s_answer_opp(i) = 1;
    end
    
    %------------------------------------------------------%
    %     PLAYER AND ALGORITHM CHOICES ARE COMPARED        %            
    %------------------------------------------------------%
    
    % ANSWERS ARE COMPARED
    if s_answer_opp(i) == 1
        logstring('Opponent Choice is A');
    elseif s_answer_opp(i) == 2
        logstring('Opponent Choice is B');
    else        
        logstring('Opponent No Answer');
    end
    
    % SAVE 4 : Answer of opponent
    Subject.opponent_response = s_answer_opp;
    
    %Determine payoff and prepare reward pic
    if (s_answer(i)>0) && (s_answer_opp(i)>0)
        s_reward(i)=sPayoff(s_answer(i),s_answer_opp(i));
        showscreen = ResultPic(s_answer(i),s_answer_opp(i)); %BRING UP to ''determine payoff''
        preparepict(text_blank,showscreen,0,140); %BRING UP to ''determine payoff''
        settextstyle('Arial',70); %BRING UP to ''determine payoff''
        preparestring(sprintf('%d pts.',s_reward(i)),showscreen,0,145);%BRING UP to ''determine payoff''
    else
        s_reward(i)=-inf;   %no payoff recieved
    end
    
    % SAVE 5 : Payoff of subject
    Subject.payoff = s_reward;
  
    % TIMING 4 : Wait for feedback event to occur
    % Compare answers, and prepare feedback. 
    
    waituntil(Event_onsets(i,2)) 
    if s_reward(i) ==-inf  %no payoff recieved
        Feedback_onset = drawpict(NullPic);
        logstring('Feedback cue')
        logstring('Null Response');
    else
        Feedback_onset = drawpict(showscreen); 
        logstring('Feedback cue')
        logstring(sprintf('%d pts. reward delivered',s_reward(i)));
    end
    
    
    %-----------------------------------------------%
    % ALGORITHM UPDATES HIS BELIEF                  %
    %-----------------------------------------------%
    
    %Properties of the algorithm
    %--------------------------------
    %The algorithm plays the Employer.
    %The algorithm seeks to match the player's choice
    %The algorithm is 'aware' of his payoff matrix
    %The algorithm is 'aware' that his choices affects his opponent 
    
    %Choice of the subject forwarded to AI
    %-----------------------------------------%
    %recode choice to correspond to model input
    Subject_choice(i) = s_answer(i)-1;
    
    %-----------------IMPORTANT------------------------%
    %If subject failed to provide answer, pass the trial
    %And do not learn from it.
    %If there is no new data, the algorithm uses its previous staT
    %to make decision.
    
    %Store algorithm beliefs for reference
    Subject.Algorithm.p_data(i) = p;    
    
    % 1st order "Fictitious play" prediction error
    %---------------------------------------------
    %Explanation... 
    %What the opponent did minus my beliefs
    %1 for WORK, 0 for SHIRK. 
    % p = 1 for 100% belief he will WORK
    
    delta1 = Subject_choice(i) - p; 
    
    % 2nd order p, i.e., pp
    %--------------------------------------------
    %What does my opponent think I thinks he will do?
    if p == 0, 
        qq = 1;
    elseif p == 1, 
        qq = 0;
        %this is to avoid negative log. 
    else
        qq = 1/2 + log((1-p)/p) / (4 * beta_yer);
        if qq > 1, qq = 1;
        elseif qq < 0, qq = 0;
        end
    end
    
    % 2nd order Prediction Error
    %---------------------------
    %Explanation
    %What does my opponent think I will do given my last action?
    %My last choice minus the stat of my second order beliefs. 
    
    %recale from 0 to 1
    choice_yer(i) = s_answer_opp(i)-1; 
    
    delta2 = choice_yer(i) - qq;
    
    %learning
    %------------------------------------------
    %Integrating first and second-order beliefs
    p = p + eta_yer * delta1 - kappa_yer * delta2;
    if p > 1, p = 1;
    elseif p < 0, p = 0;
    end
    
    %Summary
    %------------------------------------------------------------
    %The new value of "p" is then forward on the top of the loop. 
    %There it will be fed into a softmax to yield p(not inspect)
    
    
    % SAVE 6 : Onsets of feedback
    Subject.Onsets_feedback(i) = Feedback_onset-Subject.FMRI_start_byte_resp;
    
    % TIMING 5 : Show feedback event for 2.5 seconds. 
    waituntil(Feedback_onset + Time_feedback_presentation);
    Feedback_end = drawpict(NeutralPic);
    
    
    
end 

stop_cogent 

% Calculate reward 
total_reward = sum(s_reward(~isinf(s_reward)));

% Save Cogent log and Subject file
%---------------------------------------------------------
save(['S_',num2str(S_ID),'_',(datestr(now,30))], 'Subject', 'total_reward')
%save(['S_',num2str(S_ID),'_',(datestr(now,30))], 'total_reward')
%save(['S_',num2str(S_ID)], 'total_reward')


