% Analysis of intertemporal choice data
%
% experimental parameters + data stored in 'DATA'
% (c) Mona Garvert 2012
% =====================================================================================================

% add subject index
subj = {'1','2'};

for s = 1:length(subj)
    load(sprintf('../datafiles/data_%s.mat',subj{s}))
    
    %% Compute discount rates
    self1.k         = likelihoodEstimation(DATA.self1); 
    other1.k        = likelihoodEstimation(DATA.other1); 
    self2.k         = likelihoodEstimation(DATA.self2); 
    other2.k        = likelihoodEstimation(DATA.other2); 
    self3.k         = likelihoodEstimation(DATA.self3); 

    % Plot discount rate evolution over trials
    figure; plot(self1.k)
    hold on, plot(other1.k,'g')
    hold on, plot(self2.k,'--b')
    hold on, plot(other2.k,'r')
    hold on, plot(self3.k,'.b')
    
    % Can also plot other information, e.g. evolution of posterior over
    % trials
    [self1.k, ~, self1.post]   = likelihoodEstimation(DATA.self1); 
    figure; imagesc(1:10,K,self1.post)
    xlabel('Trials'),ylabel('Discount rate')
    
    % Compute learning index
    other1.learn(s)    = learning(DATA.other1);
    other2.learn(s)    = learning(DATA.other2);
    
    % Discount rate estimate to look at TD alone (presumably the first
    % measure is the cleanest here)
    k_self(s,:)     = [self1.k(end), self2.k(end), self3(end)];
    
    % Shift estimate (Can also compute shift away from other 1 etc)
    shift(s,1)      = (self2.k(end) - self1.k(end))/(other1.k(end) - self1.k(end));
    shift(s,2)      = (self3.k(end) - self2.k(end))/(other2.k(end) - self2.k(end));
    
    % How far away is the estimate of subjects' own discount rate from the
    % discount rate of the other
    dist(s,1)       = other1.k(end) - self1.k(end);
    dist(s,2)       = other2.k(end) - self2.k(end);
end

% Shift measure for subjects whose estimate is larger than a threshold
% (here 0.3) only
s1 = shift(abs(dist(:,1))>0.3,1);
s2 = shift(abs(dist(:,2))>0.3,2);

figure; 
bar([mean(s1) mean(s2)])
hold on 
errorbar(1:2,[mean(s1) mean(s2)],[std(s1) std(s2)]./[sqrt(size(s1,1)) sqrt(size(s2,1))],'k','linestyle','none')
ylabel('Discount rate shift')  
set(gca,'XTickLabel',{'shift towards other1','shift towards other2'})
    
