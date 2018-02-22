function [ experts, expertsEV ] = experts3( blockLength)
%UNTITLED Summary of this function goes here
 % Detailed explanation goes here

err = 1750;

targetEV1 = linspace(501, 999, blockLength/2)/10;
for i = 1:length(targetEV1)
accs_temp = (targetEV1(i):0.1:100)/100; %good experts    
accs1(i) = datasample(accs_temp,1);
end
costs1_max = 1-(targetEV1./100./accs1);
costs1=floor(costs1_max*10000);

for i = 1:length(costs1)
    if costs1(i)==0
        cost_temp = 0;
    else
        cost_temp = datasample(1:costs1(i),1);
    end
    costs1_res(i) = (costs1(i)-cost_temp)/10000;
    costs1(i) = cost_temp/10000;
end

EV1 = (1-costs1).*accs1;

costs_res_temp1 = sum(floor(costs1_res*10000));

targetEV2 = linspace(1, 500, blockLength/4)/10;
for i = 1:length(targetEV2)
    if targetEV2(i)<50.1
        accs_temp = (50.1:0.1:100)/100; %good experts
    else
        accs_temp = (targetEV2(i):0.1:100)/100; %good experts
    end
    accs2(i) = datasample(accs_temp,1);
end
costs2_min = 1-(targetEV2./100./accs2);
costs2=ceil(costs2_min*10000);

for i = 1:length(costs2)
    noise=randi(err);
cost_temp = datasample(1:(costs_res_temp1/4 + noise),1);
costs_res_temp1 = costs_res_temp1-cost_temp+ noise;
costs2(i) =(costs2(i)+cost_temp)/10000;
if costs2(i)>1
    costs_res_temp1 = costs_res_temp1 + (1-costs2(i));
    costs2(i)=1;
end
end

EV2 = (1-costs2).*accs2;


targetEV3 = linspace(1, 500, blockLength/4)/10;
for i = 1:length(targetEV3)
accs_temp = (targetEV3(i):0.1:50)/100; %good experts
accs3(i) = datasample(accs_temp,1);
end
costs3_min = 1-(targetEV3./100./accs3);
costs3=ceil(costs3_min*10000);

for i = 1:length(costs3)   
    noise = randi(err);
cost_temp = datasample(1:(costs_res_temp1/4 + noise),1);
costs_res_temp1 = costs_res_temp1-cost_temp+noise; %this is where charges are quite restricted
costs3(i) = (costs3(i)+cost_temp)/10000;
if costs3(i)>1
    costs_res_temp1 = costs_res_temp1 + (1-costs3(i));
    costs3(i)=1;
end
end

EV3 = (1-costs3).*accs3;

accs = [accs1 accs2 accs3];
costs = [costs1 costs2 costs3];
EVs = [EV1 EV2 EV3];

experts = [accs' costs'];
experts = experts(randperm(length(experts)),:);
experts = [experts experts(:,1)>0.5];

expertsEV = experts(:,1).*(1-experts(:,2));

experts = [experts expertsEV>0.5];
experts = [experts experts(:,3)+experts(:,4)]; % 2 codes for above 50% acc and good EV

end



