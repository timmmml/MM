function [k_trial,beta_trial,track_post] = likelihoodEstimation(FILE)

count       = 0;

K           = (-4:0.02:0)';
log_beta    = (-1:0.1:1)';

% start by initializing Kprior to be a uniform distribution, normalized
% such that integral is 1
Kprior      = ones(length(K),length(log_beta))./(length(K)*length(log_beta));

for trial = 1:length(FILE.choices)
    if FILE.subject_choice(trial)~= 0
        
        RS = FILE.choices(trial,1);
        RL = FILE.choices(trial,3);
        DL = FILE.choices(trial,4);

        VS = RS;
        VL = RL ./ (1 + (10.^K) * DL);
        if FILE.subject_choice(trial,1) == 1  %calculate the likelihood of the subject's response at each value of K
            like(:,:,trial) = 1 ./ (1 + exp(-10.^log_beta*(VS-VL)'));
        elseif FILE.subject_choice(trial,1) == 2
            like(:,:,trial) = 1 ./ (1 + exp(-10.^log_beta*(VL-VS)'));
        end
        
        % Bayes rule
        Kposterior =(Kprior.*like(:,:,trial)');
        Kposterior =Kposterior./sum(Kposterior(:));
        
        % Set Prior for next trial to posterior from last trial
        Kprior = Kposterior; 
        track_post(:,trial) = sum(Kposterior,2);
        
        % trial-by-trial estimate of discount rate k and temperature
        % parameter beta
        k_trial(trial) = sum((K.*sum(Kposterior,2)))/sum(sum(Kposterior,2));         
        beta_trial(trial) = sum((log_beta.*sum(Kposterior,1)'))/sum(sum(Kposterior,1));
    end
end