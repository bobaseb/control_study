function DATA = metaChoice_task_loss_reward()
% script for the experiment in:
% Bobadilla-Suarez, S., Sunstein, C. R. & Sharot, T. (2017). The intrinsic value of control: The propensity to under-delegate in the face of potential gains and losses. Journal of Risk and Uncertainty, 54(3), 187-202.
% Loosely based on a script from Benedetto De Martino & Steve Fleming (thanks to both)
%
%requires the cogent package, visang.m (not my code), experts3.m, & the stimuli 

% The major output from this script is a multi-leveled structure called
% DATA.
%               Modified by Sebastian Bobadilla
close all;
clc;
clear;

addpath(genpath(cd));
fprintf('Configuring Cogent and setting up experiment parameters...\n');
global cogent
%% Demographics
%subNo = input('Participant number\n');
%age = input('Age\n');
%sex = input('Sex\n','s');
global subNo age sex

DATA.params.subNo = subNo;
DATA.params.age = age;%input('\nAge\n');
DATA.params.sex = sex;%input('\nGender (M or F)\n', 's');

if randi(2)==1
    rewardFirst_prac = 1; %if subNo is even start with rewards
    rewardSecond_prac = -1;
else
    rewardFirst_prac = -1; %if subNo is odd start with losses
    rewardSecond_prac = 1;
end

sample_bal = randsample([2 4 6 8 10 12 14 16]-1,1);
counter_balance = [1 -1 1;1 -1 2;1 -1 1;-1 1 2;-1 1 1;-1 1 2;-1 1 1;1 -1 2;1 -1 2;1 -1 1;1 -1 2;-1 1 1;-1 1 2;-1 1 1;-1 1 2;1 -1 1];
DATA.block_order = counter_balance(sample_bal:sample_bal+1,:);

DATA.reward_val = 1000; %reward/loss on every trial, 10 pounds = 1000 p

DATA.params.scrdist_mm = 750; %default to this distance if left blank
DATA.params.scrwidth = 520; %screen width in mm? WE NEED TO MEASURE THIS
DATA.params.scrwidth_deg = visang(DATA.params.scrdist_mm, [], DATA.params.scrwidth); % horizontal screen dimension in degrees
DATA.params.pixperdeg = 1600/DATA.params.scrwidth_deg; %assuming a resolution of 1280 pixels CHECK THIS!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% COGENT: CONFIGURATION
% display parameters
screenMode = 0;                 % 0 for small window, 1 for full screen, 2 for second screen if attached
screenRes = 5;                 % 6 = 1280 x 1024 resolution
white = [1 1 1];                % foreground colour
black = [0 0 0];                % background colour
red = [1 0 0];
fontName = 'Arial';         % font parameters
fontSize = 32;
DATA.fontSize = fontSize;
number_of_buffers = 20;          % how many offscreen buffers to create
rand('seed',sum(100*clock));
% call config_... to set up cogent environment, before starting cogent
config_display(screenMode, screenRes, white, black, fontName, fontSize, number_of_buffers);   % open graphics window
%config_display(screenMode, screenRes, black, white, fontName, fontSize, number_of_buffers);   % open graphics window
config_keyboard;                % this enables collection of keyboard responses
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start_cogent;

%%  Store params
DATA.params.stimuli = 8;
DATA.leftKey = 26;   % z
DATA.rightKey = 24;  % x
DATA.yesKey = 25; %y=25
DATA.noKey = 1; %a=1
DATA.nextKey = 14; %n
DATA.backKey = 2; %b

DATA.times.confirm = 1000;
DATA.times.fix = 500;
DATA.times.choice = inf; %2 second response time deadline, now changed to inf
DATA.times.wait = 5000; %minimum wait time
speed = 0;
DATA.numSess = 3; %if you change this to 6 you'll get back the speeded/slow design
DATA.params.blockLength = 8;%change for debugging, minimum is 8 for beginning, max 60*******************************************************
DATA.params.alltrials = DATA.params.blockLength*3; %multiplies by number of superblocks (*2 is number of blocks)
DATA.params.randStim = randperm(DATA.params.alltrials*2); %then for pairs of stimuli
DATA.params.randStim = [DATA.params.randStim(1:DATA.params.alltrials)' DATA.params.randStim(DATA.params.alltrials+1:DATA.params.alltrials*2)'];

DATA.params.randStim = reshape(DATA.params.randStim,DATA.params.blockLength,DATA.numSess*2);
%DATA.params.randStim = reshape(DATA.params.randStim,DATA.params.blockLength/2,12);

DATA.params.prac1wins = [zeros(DATA.params.blockLength/4,1); ones(DATA.params.blockLength/4,1)];
DATA.params.prac1wins = DATA.params.prac1wins(randperm(length(DATA.params.prac1wins)));
DATA.params.prac2wins = [zeros(DATA.params.blockLength/4,1); ones(DATA.params.blockLength/4,1)];
DATA.params.prac2wins = DATA.params.prac2wins(randperm(length(DATA.params.prac2wins)));


[ DATA.params.experts_test1, DATA.params.expertsEV_test1 ] = experts3( DATA.params.blockLength); %4 is the minimum for experts3 function
[ DATA.params.experts_test2, DATA.params.expertsEV_test2 ] = experts3( DATA.params.blockLength);
%[ DATA.params.experts_test3, DATA.params.expertsEV_test3 ] = experts3( DATA.params.blockLength/2);
%[ DATA.params.experts_test4, DATA.params.expertsEV_test4 ] = experts3( DATA.params.blockLength/2);

%imsize= DATA.params.pixperdeg*DATA.params.scrwidth_deg;
%happiness_scale();

% welcome screen

preparestring('Decision making experiment instructions:',1,0,340);
preparestring('Thank you for agreeing to participate in this experiment on decision making.',1,0,290);
preparestring('You will be compensated £7 per hour in addition to rewards (or losses) ',1,0,250);
preparestring('you accumulate in the experiment.',1,0,210);
preparestring('The experiment has 4 sessions and should ',1,0,170);
preparestring('take approximately forty minutes.',1,0,130);
preparestring('If at any time you no longer wish to continue with the experiment, ',1,0,90);
preparestring('you are free to leave at any point. ',1,0,50);
preparestring('In these circumstances you will receive a partial reimbursement of £4. ',1,0,10);
preparestring('PRESS ANY KEY TO CONTINUE',1,0,-90);
drawpict(1);
waitkeydown(inf);
clearpict(1);
clearpict



% Run training trials
for j = 1:2
    DATA.training = 1;
    
    if j == 1
        %DATA.trialList = DATA.params.randStim(:,1:2);
        DATA.trialList = DATA.params.randStim(1:size(DATA.params.randStim,1)/2,1:2);
        DATA.reward_prac = rewardFirst_prac;
        DATA.prac_wins = DATA.params.prac1wins;
    elseif j == 2
        %DATA.trialList = DATA.params.randStim(:,3:4);
        DATA.trialList = DATA.params.randStim((size(DATA.params.randStim,1)/2)+1:end,1:2);
        DATA.reward_prac = rewardSecond_prac;
        DATA.prac_wins = DATA.params.prac2wins;
    end
    
    %% Write instructions on screen
    preparestring('Welcome to this session!',1,0,340);
    preparestring('On each trial two figures will appear simultaneously on the screen, e.g.:',1,0,290);
    loadpict('practice_stim1.bmp',1,-200,150); loadpict('practice_stim6.bmp',1,200,150);
    preparestring('Every pair of figures will be different on every trial. ',1,0,0);
    if (rewardFirst_prac == 1 && j == 1) || (rewardSecond_prac == 1 && j == 2)
        preparestring('Your task is to find patterns that may make some figures more likely to WIN you money.',1,0,-100);
        preparestring('For each pair, one of the figures, but not the other, can WIN you 10 pounds.',1,0,-150);
        preparestring('Your task is to try and select the WINNING figure by pressing the "Z" key',1,0,-200);
    else
        preparestring('Your task is to find patterns that may make some figures more likely to LOSE you money.',1,0,-100);
        preparestring('For each pair, one of the figures, but not the other, can LOSE you 10 pounds.',1,0,-150);
        preparestring('Your task is to try and select the figure that AVOIDS LOSING by pressing the "Z" key',1,0,-200);
    end
    preparestring('to select the symbol on the left and the "X" key to select the symbol on the right.',1,0,-250);
    preparestring('At the end of the experiment we will sample 10 trials at random',1,0,-300);
    preparestring('and add the average win to your compensation.',1,0,-350);
    preparestring('PRESS ANY KEY TO CONTINUE',1,0,-400);
    drawpict(1);
    waitkeydown(inf);
    clearpict(1);
    clearpict
    
    %preparestring('NOTE:',1,0,100);
    %preparestring('Be careful, you only have 10 seconds to indicate your answer otherwise you will lose 10p.',1,0,0);
    if (rewardFirst_prac == 1 && j == 1) || (rewardSecond_prac == 1 && j == 2)
        preparestring('Try to pick the symbol that you find to have the highest chance of WINNING',1,0,-50);
    else
        preparestring('Try to pick the symbol that you find to have the highest chance of NOT LOSING',1,0,-50);
    end
    preparestring('in order to maximize your earnings.',1,0,-100);
    preparestring('At first you may be confused, but don''t worry, you''ll have plenty of practice!',1,0,-150);
    preparestring('You will start this task with 7 pounds.',1,0,-200);
    preparestring('PRESS ANY KEY TO START',1,0,-300);
    drawpict(1);
    waitkeydown(inf);
    clearpict(1);
    clearpict
    
    
    %%
    
    DATA = runTrials(DATA);
    datafile = sprintf('metaChoiceTask_sub%d_trainBlock%d', subNo, j);
    save(datafile,'DATA');
    fprintf('Data saved in %s\n',datafile);
    
end

%% Run testing trials
clearpict
clearpict(1)
preparestring('End of the training phase. Well done!',1,0,200);
preparestring('The task is the same as for the training sessions with two differences:',1,0,150);
preparestring('1. You have the option to select the figure yourself out of the pair, or ask an "advisor" to select for you.',1,0,100);
preparestring('On each trial there will be a different advisor. Each advisor has a different rate of success on this task.',1,0,50);
preparestring('Each advisor was generated by a computer algorithm and the answers from that algorithm were stored previously.',1,0,0);
preparestring('You will be told the success rate of the advisor and the charges for picking the figure.',1,0,-50);
preparestring('For example, lets say you are offered an advisor with ',1,0,-100);
preparestring('a 90% success rate of selecting figures correctly who charges £5.',1,0,-150);
preparestring('You decide to "hire" the advisor and the advisor picks correctly, you will thus receive £5 (£10-£5).',1,0,-200);
% preparestring('NOTE: Use the UP ARROW key for "Yes I would like to choose myself"',1,0,-200);
% preparestring('or the DOWN ARROW key for "No I would like someone else to choose for me"',1,0,-250);
preparestring('PRESS ANY KEY TO CONTINUE',1,0,-250);
drawpict(1);
waitkeydown(inf);
clearpict(1)
clearpict

preparestring('2. There will be no feedback in this session so you will not know',1,0,250);
preparestring('until the very end of the session whether your choices were good ones.',1,0,200);
preparestring('NOTE: Use the "Y" key or the "A" key"',1,0,150);
preparestring('to determine who will make the choice, you ("Y") or the advisor ("A")."',1,0,100);
preparestring('If you want to make the choice yourself, then choosing between figures is the same as before.',1,0,50);
preparestring('Use the "Z" key for left and the "X" key for right.',1,0,0);
preparestring('After completing the test phase you will be told',1,0,-50);
preparestring('how much money you have earned and it will be added to your base pay.',1,0,-100);
preparestring('Therefore, it is in your best interest to make choices that would maximise your pay.',1,0,-150);
if speed == 1
    preparestring('NOTE: You will have to wait 5 SECONDS before deciding between you or the advisor.',1,0,-200);
end

preparestring('PRESS ANY KEY TO START',1,0,-350);
drawpict(1);
waitkeydown(inf);
clearpict(1)
clearpict

preparestring('You will start the task with 7 pounds.',1,0,250);
for j = 1:2 %4 testing phases, changed to 2 testing phases
    %1 = slow, 2= 2 second time limit
    
    %         if (j<3 && DATA.block_order(1,3) ==1) || (j>2 && DATA.block_order(1,3) ==2)
    %             clearpict(1)%***************************************************************************************************************************
    %             preparestring('NOTE: You will have to WAIT 5 seconds before you can determine who will make a decision.',1,0,0);
    %             preparestring('Remember to use the "Y" key for you and the "A" key for the advisor.',1,0,-50);
    %         else
    %             clearpict(1)%***************************************************************************************************************************
    %             preparestring('NOTE: This is a fast block, you will ONLY have 2 seconds to determine who makes the decision.',1,0,0);
    %             preparestring('Remember to use the "Y" key for you and the "A" key for the advisor.',1,0,-50);
    %         end
    % DATA.happiness(j) = happiness_scale();%***************************************************************************************
    % DATA.happiness(j) = DATA.happiness(j)/70;
    
    if (j==1&&DATA.block_order(1,1)==-1)||(j==2&&DATA.block_order(1,2)==-1)||(j == 3&&DATA.block_order(2,1)==-1)||(j==4&&DATA.block_order(2,2)==-1)
        preparestring('In this block you will have only trials with LOSSES.',1,0,200);
        preparestring('Try to make the choices that best avoid your LOSSES.',1,0,150);
        preparestring('Remember to use the "Y" key for you and the "A" key for the advisor.',1,0,100);
        preparestring('If you want to make the choice yourself, then choosing between figures is the same as before.',1,0,50);
        preparestring('Use the "Z" key for left and the "X" key for right.',1,0,0);
        drawpict(1);
        waitkeydown(inf);
        clearpict(1)
        clearpict
    else
        preparestring('In this block you will have only trials with REWARDS.',1,0,200);
        preparestring('Try to make the choices that best maximize your earnings.',1,0,150);
        preparestring('Remember to use the "Y" key for you and the "A" key for the advisor.',1,0,100);
        preparestring('If you want to make the choice yourself, then choosing between figures is the same as before.',1,0,50);
        preparestring('Use the "Z" key for left and the "X" key for right.',1,0,0);
        drawpict(1);
        waitkeydown(inf);
        clearpict(1)
        clearpict
    end
    
    if j == 1
        %DATA.trialList = DATA.params.randStim(:,5:6);
        DATA.trialList = DATA.params.randStim(:,3:4);
        DATA.expAcc = DATA.params.experts_test1(:,1);
        DATA.expCharge = DATA.params.experts_test1(:,2);
        DATA.reward = DATA.block_order(1,1);
        %DATA.speed = DATA.block_order(1,3);
        DATA.speed = speed;
    elseif j == 2
        %DATA.trialList = DATA.params.randStim(:,7:8);
        DATA.trialList = DATA.params.randStim(:,5:6);
        DATA.expAcc = DATA.params.experts_test2(:,1);
        DATA.expCharge = DATA.params.experts_test2(:,2);
        DATA.reward = DATA.block_order(1,2);
        %DATA.speed = DATA.block_order(1,3);
        DATA.speed = speed;
    elseif j == 3
        DATA.trialList = DATA.params.randStim(:,9:10);
        DATA.expAcc = DATA.params.experts_test3(:,1);
        DATA.expCharge = DATA.params.experts_test3(:,2);
        DATA.reward = DATA.block_order(2,1);
        DATA.speed = DATA.block_order(2,3);
    elseif j == 4
        DATA.trialList = DATA.params.randStim(:,11:12);
        DATA.expAcc = DATA.params.experts_test4(:,1);
        DATA.expCharge = DATA.params.experts_test4(:,2);
        DATA.reward = DATA.block_order(2,2);
        DATA.speed = DATA.block_order(2,3);
    end
    
    DATA.training = 0;
    DATA = runTrials(DATA);
    datafile = sprintf('metaChoiceTask_sub%d_testPhase%d', subNo, j);
    
    stoploop=0;
    if j==2 %change this to 4 to get back speeded/slow design
        %DATA.happiness(3) = happiness_scale();%***************************************************************************************
        %DATA.happiness(3) = DATA.happiness(3)/70;
        while stoploop == 0
            clearpict(1)%***************************************************************************************************************************
            preparestring('Before ending the experiment, could you please provide',1,0,200);%deciding whether to choose or to defer to the advisor
            preparestring('an estimate of how accurate you think you were in choosing the CORRECT FIGURE?',1,0,150);
            preparestring('Please type in a number from 1% to 99%.',1,0,100);
            preparestring('There is no need to type the "%" sign. Please use the top number keys (not the side ones).',1,0,50);
            drawpict(1);
            [key,t] = waitkeydown(inf,27:36); %waits for number keys
            digit1 = sprintf('%d',key-27);
            preparestring(digit1,1,0,0);
            drawpict(1);
            [key,t] = waitkeydown(inf,27:36); %waits for number keys
            digit2 = sprintf('%d',key-27);
            preparestring(digit2,1,20,0);
            preparestring('Are you sure this was your accuracy? Press "N" to go on or "B" to put in a different number.',1,0,-50);
            drawpict(1);
            [key,t] = waitkeydown(inf,[DATA.nextKey DATA.backKey]);
            
            if key==DATA.nextKey
                DATA.guessAcc = sprintf('%s%s',digit1,digit2);
                clearpict(1)
                clearpict
                stoploop = 1;
            end
            
        end
        
        stoploop=0;
        clearpict(1)%***
        preparestring('Now, to go on to a different question, press any key to continue.',1,0,100);
        drawpict(1);
        waitkeydown(inf)
        while stoploop == 0
            clearpict(1)%***************************************************************************************************************************
            preparestring('Now, could you please provide an estimate of how accurate you think you were',1,0,200);%
            preparestring(' in deciding whether to CHOOSE or to DEFER to the advisor?',1,0,150);
            preparestring('Please type in a number from 1% to 99%.',1,0,100);
            preparestring('There is no need to type the "%" sign. Please use the top number keys (not the side ones).',1,0,50);
            drawpict(1);
            [key,t] = waitkeydown(inf,27:36); %waits for number keys
            digit1 = sprintf('%d',key-27);
            preparestring(digit1,1,0,0);
            drawpict(1);
            [key,t] = waitkeydown(inf,27:36); %waits for number keys
            digit2 = sprintf('%d',key-27);
            preparestring(digit2,1,20,0);
            preparestring('Are you sure this was your accuracy? Press "N" to go on or "B" to put in a different number.',1,0,-50);
            drawpict(1);
            [key,t] = waitkeydown(inf,[DATA.nextKey DATA.backKey]);
            
            if key==DATA.nextKey
                DATA.guessAcc_metaChoice = sprintf('%s%s',digit1,digit2);
                clearpict(1)
                clearpict
                stoploop = 1;
            end
            
        end
    end
    
    save(datafile,'DATA');
    fprintf('Data saved in %s\n',datafile);
end

clearpict(1)%***
preparestring('Just a couple of more questions...',1,0,200);%
preparestring('Which block made you happier? Losses or Gains? Put 1 for Losses or 2 for Gains.',1,0,150);%null=1.5
drawpict(1);
[key,t] = waitkeydown(inf,28:29); %only accept 1 or 2?
DATA.Qs.one = key-27;
clearpict(1)%***
preparestring('If you had to do one more block which one would you prefer, Losses or Gains?',1,0,150);%null=1.5
preparestring('Put 1 for Losses or 2 for Gains.',1,0,100);
drawpict(1);
[key,t] = waitkeydown(inf,28:29); %only accept 1 or 2?
DATA.Qs.two = key-27;
clearpict(1);
preparestring('How much would you pay to do the Gains block again?',1,0,150);%paired ttest with next question
preparestring('Put in a number from 0 to 9 pounds.',1,0,100);
drawpict(1);
[key,t] = waitkeydown(inf,27:36); 
DATA.Qs.three = key-27;
clearpict(1);
preparestring('How much would you pay to do the Loss block again?',1,0,150);%
preparestring('Put in a number from 0 to 9 pounds.',1,0,100);
drawpict(1);
[key,t] = waitkeydown(inf,27:36); 
DATA.Qs.four = key-27;
clearpict(1);

save(datafile,'DATA');
fprintf('Data saved in %s\n',datafile);

clearpict(1);
preparestring('Congratulations! You just finished the first experiment!',1,0,100);
preparestring('Before the experiment ends and we give you your final compensation,',1,0,0);
preparestring('please go on to the next screens to do the second experiment.',1,0,-50);
preparestring('PRESS ANY KEY TO CONTINUE',1,0,-100);
drawpict(1);
% Wait for keypress before continuing
waitkeydown(inf);
clearpict
clearpict(1);



stop_cogent;
return

function DATA = runTrials(DATA)
%% type II response screen
pixperdeg = DATA.params.pixperdeg;
imsize= pixperdeg*DATA.params.scrwidth_deg;
cgmakesprite(2,imsize,imsize,0,0,0);
fig_pos = [-5,-3,-1,1,3,5] * pixperdeg;
cgfont('Arial',25);
cgsetsprite(2)
cgtext('1',fig_pos(1),0);
cgtext('2',fig_pos(2),0);
cgtext('3',fig_pos(3),0);
cgtext('4',fig_pos(4),0);
cgtext('5',fig_pos(5),0);
cgtext('6',fig_pos(6),0);

cwd = pwd;
for i = 1:size(DATA.trialList,1)
    % Prepare confidence selection square in buffer 4 - for some
    % annoying reason this needs to be put here again, otherwise cogent
    % forgets that the background needs to be trasnparent
    %DATA.rewardStruct = DATA.rewardStruct*DATA.reward;
    fontSize = DATA.fontSize;
    
    cgmakesprite(4,imsize,imsize,1,1,0);
    cgsetsprite(4)
    cgpenwid(pixperdeg*.1);
    cgpencol(1,0,0)
    cgdraw(-pixperdeg, -pixperdeg, pixperdeg, -pixperdeg);
    cgdraw(-pixperdeg, -pixperdeg, -pixperdeg, pixperdeg);
    cgdraw(-pixperdeg, pixperdeg, pixperdeg, pixperdeg);
    cgdraw(pixperdeg, pixperdeg, pixperdeg, -pixperdeg);
    cgtrncol(4,'y')
    cgpencol(1,1,1)
    
    clearkeys
    
    cgmakesprite(3,imsize,imsize,1,1,0);
    cgsetsprite(3)
    cgpenwid(.1*pixperdeg);
    cgpencol(1,0,0)
    cgdraw(-pixperdeg, -pixperdeg, pixperdeg, -pixperdeg);
    cgdraw(-pixperdeg, -pixperdeg, -pixperdeg, pixperdeg);
    cgdraw(-pixperdeg, pixperdeg, pixperdeg, pixperdeg);
    cgdraw(pixperdeg, pixperdeg, pixperdeg, -pixperdeg);
    cgtrncol(3,'y')   %% this sets background as yellow which will later be transparent so can see numbers through buffer.
    cgpencol(1,1,1)
    % Load pics into buffers 4
    clearpict(4);
    loadpict([sprintf('stim%d',DATA.trialList(i,1)) '.bmp'],4,-250,-200,300,300);
    loadpict([sprintf('stim%d',DATA.trialList(i,2)) '.bmp'],4,175,-200,300,300);
    cgfont('Arial',fontSize+10);
    cgtext('Who will choose?',0,300);
    cgtext('You       or       Advisor',0,250);
    
    yval = 100;
    cgtext('Advisor''s Accuracy: ',-350,yval);
    cgtext('Advisor''s Charge: ',150,yval);
    %clearpict(5)
    
    if DATA.training == 0
        DATA.rewardStruct(i) = DATA.reward_val*DATA.reward/100;
    else
        DATA.rewardStruct(i) = DATA.reward_val*DATA.reward_prac/100;
    end
    
    if DATA.training == 0
        
        expAcc = round(DATA.expAcc(i)*1000)/10;
        expCharge = round(DATA.expCharge(i)*DATA.reward_val);
        
        if DATA.reward == -1 %losses
            expert_textAcc = sprintf('%g%%', expAcc);
            expert_textChg = sprintf('%g p', expCharge);
        elseif DATA.reward == 1 %gains
            expert_textAcc = sprintf('%g%%', expAcc);
            expert_textChg = sprintf('%g p', expCharge);
        end
        cgpencol(1,0,0)
        cgtext(expert_textAcc, -100, yval);
        cgtext(expert_textChg, 375, yval);
        cgpencol(0,0,0)
    end
    
    %reward_text = sprintf('This trial is worth %d pounds', DATA.rewardStruct(i));
    %cgtext(reward_text, 0, 400);
    
    clearpict(5);
    loadpict([sprintf('stim%d',DATA.trialList(i,1)) '.bmp'],5,-250,0,300,300);
    loadpict([sprintf('stim%d',DATA.trialList(i,2)) '.bmp'],5,175,0,300,300);
    cgfont('Arial',fontSize+10);
    %clearpict(5)
    cgtext('Which figure?',0,200);
    %reward_text = sprintf('This trial is worth %d pounds', DATA.rewardStruct(i));
    %cgtext(reward_text, 0, 300);
    
    clearpict(6);
    loadpict([sprintf('stim%d',DATA.trialList(i,1)) '.bmp'],6,-250,0,300,300);
    loadpict([sprintf('stim%d',DATA.trialList(i,2)) '.bmp'],6,175,0,300,300);
    cgfont('Arial',fontSize+10);
    cgtext('Advisor is choosing...',0,200);
    
    
    if DATA.training == 0
        clearpict(7);
        %loadpict([sprintf('stim%d',DATA.trialList(i,1)) '.bmp'],7,-250,0,300,300);
        %loadpict([sprintf('stim%d',DATA.trialList(i,2)) '.bmp'],7,175,0,300,300);
        cgfont('Arial',fontSize+10);
        %cgtext(expert_text, 0, 350);
        cgtext('Who will choose?',0,300);
        cgtext('You       or       Advisor',0,250);
        cgtext('Advisor''s Accuracy: ',-350,0);
        cgtext('Advisor''s Charge: ',150,0);
        cgpencol(1,0,0)
        cgtext(expert_textAcc, -100, yval);
        cgtext(expert_textChg, 375, yval);
        cgpencol(0,0,0)
        % cgtext('Please wait 5 seconds.',0,200);
        
        clearpict(8);
        %loadpict([sprintf('stim%d',DATA.trialList(i,1)) '.bmp'],8,-250,0,300,300);
        %loadpict([sprintf('stim%d',DATA.trialList(i,2)) '.bmp'],8,175,0,300,300);
        cgfont('Arial',fontSize+10);
        
        cgtext('Who will choose?',0,300);
        cgtext('You       or       Advisor',0,250);
        cgtext('Advisor''s Accuracy: ',-350,0);
        cgtext('Advisor''s Charge: ',150,0);
        cgpencol(1,0,0)
        cgtext(expert_textAcc, -100, yval);
        cgtext(expert_textChg, 375, yval);
        cgpencol(0,0,0)
        cgtext('Choose',0,-200);
        
        
        
    end
    cgfont('Arial',fontSize);
    cd(cwd);
    
    %% Display stimuli
    cgsetsprite(0);
    clearkeys;
    cgfont('Arial',fontSize);
    cgtext('+',0,0);
    cgflip(1,1,1);
    wait(DATA.times.fix);
    
    %DATA.training = 0; %for debugging*************************************************
    
    % Log choice, redraw screen with choice indicator
    if DATA.training == 0 %if training == 0 go to test phase
        
        tChoice = time;
        
        if DATA.speed == 1
            cgdrawsprite(7,0,0);
            cgflip(1,1,1);
            wait(DATA.times.wait)
            %tChoice = time;
            cgdrawsprite(8,0,0);
            cgflip(1,1,1);
            [key,t] = waitkeydown(inf,[DATA.yesKey DATA.noKey]);
        else
            cgdrawsprite(4,0,0);
            %tChoice = time;
            cgflip(1,1,1);
            [key,t] = waitkeydown(DATA.times.choice,[DATA.yesKey DATA.noKey]); %25=y 1=a
        end
        
        if ~isempty(key)
            
            if key == DATA.yesKey %yes
                DATA.metaChoice(i) = 1; DATA.metaChoice_RT(i) = t(1) - tChoice;
                cgdrawsprite(5,0,0);
                tChoice = time;
                cgflip(1,1,1);
                clearkeys;
                [key,t] = waitkeydown(inf,[26 24]);
                
                if ~isempty(key)
                    
                    if key == DATA.leftKey
                        cgdrawsprite(5,0,0);
                        %cgtext('*',-250,200);
                        DATA.choice.codeI(i) = 1;
                        DATA.choice_RT(i) = t(1) - tChoice;
                        DATA.choice.codeII(i) = DATA.trialList(i,1);
                        %DATA.choice.correct(i) = max(DATA.trialList(i,:)) == DATA.trialList(i,1);
                        DATA.outcome(i) = randi(2)-1; %save the hypothetical outcomes for the final payoff
                        if DATA.outcome(i)==1
                            if DATA.reward == 1
                                DATA.rewardz(i) = DATA.reward_val;
                            else
                                DATA.rewardz(i) = 0;
                            end
                        else
                            if DATA.reward == 1
                                DATA.rewardz(i) = 0;
                            else
                                DATA.rewardz(i) = -DATA.reward_val;
                            end
                        end
                    elseif key == DATA.rightKey
                        cgdrawsprite(5,0,0);
                        DATA.choice.codeI(i) = 2;
                        DATA.choice_RT(i) = t(1) - tChoice;
                        DATA.choice.codeII(i) = DATA.trialList(i,2);
                        %DATA.choice.correct(i) = max(DATA.trialList(i,:)) == DATA.trialList(i,2);
                        DATA.outcome(i) = randi(2)-1; %save the hypothetical outcomes for the final payoff
                        
                        if DATA.outcome(i)==1
                            if DATA.reward == 1
                                DATA.rewardz(i) = DATA.reward_val;
                            else
                                DATA.rewardz(i) = 0;
                            end
                        else
                            if DATA.reward == 1
                                DATA.rewardz(i) = 0;
                            else
                                DATA.rewardz(i) = -DATA.reward_val;
                            end
                        end
                        %cgtext('*',250,200);
                    end
                    
                else
                    
                    DATA.choice.codeI(i) = -7;
                    DATA.choice_RT(i) = -7; %-7 means missed response on actual choice
                    DATA.choice.codeII(i) = -7;
                    %DATA.choice.correct(i) = -7;
                    DATA.outcome(i) = -10; %-10p for missed response
                    cgtext('Oops! Missed response!',0,0);
                    wait(500)
                end
                
            elseif key == DATA.noKey %negative answer for the metachoice
                %cgflip(1,1,1);
                
                expert_wait = 2000; % 2 seconds
                wait_noise = randi(1000)-500;
                DATA.expert_wait(i) = expert_wait + wait_noise;
                %wait(DATA.expert_wait(i))
                %chunks = 3;
                %chunk_time = DATA.expert_wait/chunks;
                
                %  for w = 1:(chunks/3)
                %                 cgdrawsprite(6,0,0);
                %                 cgflip(1,1,1);
                %                 wait(chunk_time)
                %                 cgdrawsprite(7,0,0);
                %                 cgflip(1,1,1);
                %                 wait(chunk_time)
                cgdrawsprite(6,0,0);
                cgflip(1,1,1);
                wait(DATA.expert_wait(i))
                %end
                
                DATA.metaChoice(i) = 2;
                DATA.metaChoice_RT(i) = t(1) - tChoice;
                
                % DATA.outcome(i) = randi(2)-1; %save the hypothetical outcomes for the final payoff
                
                if expAcc>randi(100)
                    DATA.outcome(i) = 1;
                    if DATA.reward == 1
                        DATA.rewardz(i) = DATA.reward_val-expCharge;
                    else
                        DATA.rewardz(i) = -expCharge;
                    end
                else
                    DATA.outcome(i) = 0;
                    if DATA.reward == 1
                        DATA.rewardz(i) = 0;
                    else
                        DATA.rewardz(i) = -DATA.reward_val;
                    end
                end
                
                DATA.choice.codeI(i) = -5;
                DATA.choice_RT(i) = -5; %-5 means subject defaulted
                DATA.choice.codeII(i) = -5;
                %DATA.choice.correct(i) = -5;
            end
            
        else
            DATA.metaChoice(i) = -6;
            DATA.metaChoice_RT(i) = -6; %-6 means missed response on metachoice
            DATA.choice.codeI(i) = -6;
            DATA.choice_RT(i) = -6;
            DATA.choice.codeII(i) = -6;
            %DATA.choice.correct(i) = -6;
            DATA.outcome(i) = -10; %-10p for missed response
            cgtext('Oops! Missed response!',0,0);
            wait(500)
        end
        
        
    elseif DATA.training == 1 %if training == 1 go to training
        cgdrawsprite(5,0,0);
        tChoice = time;
        cgflip(1,1,1);
        [key,t] = waitkeydown(inf,[26 24]);
        
        if ~isempty(key)
            
            if key == DATA.leftKey
                cgdrawsprite(5,0,0);
                cgtext('*',-250,200);
                DATA.choice.codeI(i) = 1;
                DATA.choice_RT(i) = t(1) - tChoice;
                DATA.choice.codeII(i) = DATA.trialList(i,1);
                %DATA.choice.correct(i) = max(DATA.trialList(i,:)) == DATA.trialList(i,1);
                
                if DATA.prac_wins(i)==0
                    DATA.outcome(i) = 0; %no win
                    DATA.rewardz(i) = DATA.reward_val*DATA.reward_prac;
                    cgflip(1,1,1);
                    cgfont('Arial',fontSize+10);
                    if DATA.reward_prac == 1
                        cgtext('0 pounds',0,0);
                    elseif DATA.reward_prac == -1
                        cgtext('-10 pounds',0,0);
                    end
                    wait(1000)
                else
                    DATA.outcome(i) = 1; %win!
                    DATA.rewardz(i) = DATA.reward_val*DATA.reward_prac;
                    cgflip(1,1,1);
                    cgfont('Arial',fontSize+10);
                    if DATA.reward_prac == 1
                        cgtext('+10 pounds',0,0);
                    elseif DATA.reward_prac == -1
                        cgtext('0 pounds',0,0);
                    end
                    wait(1000)
                end
                
            elseif key == DATA.rightKey
                cgdrawsprite(5,0,0);
                DATA.choice.codeI(i) = 2;
                DATA.choice_RT(i) = t(1) - tChoice;
                DATA.choice.codeII(i) = DATA.trialList(i,2);
                %DATA.choice.correct(i) = max(DATA.trialList(i,:)) == DATA.trialList(i,2);
                cgtext('*',250,200);
                
                if DATA.prac_wins(i)==0
                    DATA.outcome(i) = 0; %no win
                    DATA.rewardz(i) = DATA.reward_val*DATA.reward_prac;
                    cgflip(1,1,1);
                    cgfont('Arial',fontSize+10);
                    if DATA.reward_prac == 1
                        cgtext('0 pounds',0,0);
                    elseif DATA.reward_prac == -1
                        cgtext('-10 pounds',0,0);
                    end
                    wait(1000)
                else
                    DATA.outcome(i) = 1; %win!
                    DATA.rewardz(i) = DATA.reward_val*DATA.reward_prac;
                    cgflip(1,1,1);
                    cgfont('Arial',fontSize+10);
                    if DATA.reward_prac == 1
                        cgtext('+10 pounds',0,0);
                    elseif DATA.reward_prac == -1
                        cgtext('0 pounds',0,0);
                    end
                    wait(1000)
                end
            end
            
        else
            DATA.choice.codeI(i) = -7;
            DATA.choice_RT(i) = -7; %-7 means missed response on actual choice
            DATA.choice.codeII(i) = -7;
            %DATA.choice.correct(i) = -7;
            DATA.outcome(i) = -10; %-10p for missed response
            cgtext('Oops! Missed response!',0,0);
            wait(500)
        end
    end
    
    cgfont('Arial',fontSize);
    cgflip(1,1,1);
    wait(DATA.times.confirm);
    
end
clearpict(1);
preparestring('End of block. Please take a break.',1,0,0);
preparestring('Press any key to continue.',1,0,-100);
drawpict(1);
% Wait for keypress before continuing
waitkeydown(inf);
clearpict
clearpict(1);
