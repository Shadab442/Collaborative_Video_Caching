clc
close all
clear all

%% Video Quality Consideration

% quality = 0 if not considered
% quality = 1 if considered

quality = 1;

%% Two different "Dataset" options: Choose either "Youtube" or "Netflix"

Dataset = "Netflix";

if strcmp (Dataset,"Youtube")
    filename = "Youtube_video_requests.txt";
else
    filename = "Netflix_video_requests.txt";
end


%% Random Video requests generated from data

req = table2cell(readtable(filename));


%% General Netwok Parameters

d = 500*10^-3; % Local Propagation Delay
D = 5000*10^-3; % Remote Propagation Delay

N = 4; % Number of SBSs

if strcmp(Dataset,"Youtube")
    C = 0.002 * 10^12*ones(1,N); % Cache Space 2GB
else
    C = 500 * 10^9*ones(1,N); % Cache Space 500 GB
end

w_l = 5000:5000:80000; % Window length
alpha = 0.1:0.1:0.9;  % Discounting parameter


%% Time Evolution: alpha = 0.4 and window length = 35000

[a_rtb_,a_ltb_,a_rfb_,a_lfb_,a_dc_]  = dynamic_optimization(Dataset,'Time Evolution',quality,req,d,D,C,w_l(7),alpha(4));


%% Effect of alpha with window length = 35000

a_rtb = zeros (1,length(alpha));
a_ltb = zeros (1,length(alpha));
a_rfb = zeros (1,length(alpha));
a_lfb = zeros (1,length(alpha));
a_dc = zeros (1,length(alpha));

for i = 1:length(alpha)
    [a_rtb(i),a_ltb(i),a_rfb(i),a_lfb(i),a_dc(i)]  = dynamic_optimization(Dataset,'Effect of alpha',quality,req,d,D,C,w_l(7),alpha(i));
end 

figure;
plot(alpha, (a_rtb + a_rfb)/(10^9),'-ob','MarkerFaceColor','k','Linewidth',2)
hold on;
plot(alpha, a_rtb/(10^9),'--xr','MarkerFaceColor','k','Linewidth',2)
xlabel('alpha')
grid on;
ylabel('Average Fetched Bytes per Request (GB)')
%legend('Remote Bytes inc. Reopt.','Local Bytes inc. Reopt.','Remote Bytes exc. Reopt.','Local Bytes exc. Reopt.')
legend('Remote Fetched Bytes inc. Reopt.','Remote Fetched Bytes exc. Reopt.')

figure;
plot(alpha, (a_ltb + a_lfb)/(10^9),'-ob','MarkerFaceColor','k','Linewidth',2)
hold on;
plot(alpha, a_ltb/(10^9),'--xr','MarkerFaceColor','k','Linewidth',2)
xlabel('alpha')
grid on;
ylabel('Average Fetched Bytes per Request (GB)')
legend('Local Fetched Bytes inc. Reopt.','Local Fetched Bytes exc. Reopt.')

figure;
plot(alpha, a_dc,'-x','MarkerFaceColor','k','Linewidth',2)
xlabel('alpha')
ylabel('Average Delay per request (s)')
grid on;


%% Effect of window length with alpha = 0.4

a_rtb = zeros (1,length(w_l));
a_ltb = zeros (1,length(w_l));
a_rfb = zeros (1,length(w_l));
a_lfb = zeros (1,length(w_l));
a_dc = zeros (1,length(w_l));

for i = 1:length(w_l)
    [a_rtb(i),a_ltb(i),a_rfb(i),a_lfb(i),a_dc(i)]  = dynamic_optimization(Dataset,'Effect of window length',quality,req,d,D,C,w_l(i),alpha(4));
end

figure;
plot(w_l, (a_ltb+ a_lfb)/(10^9),'-ob','MarkerFaceColor','k','Linewidth',2)
hold on;
plot(w_l, a_ltb/(10^9),'--xr','MarkerFaceColor','k','Linewidth',2)
grid on;
xlabel('Window length')
ylabel('Average Fetched Bytes per Request (GB)')
legend('Local Fetched Bytes inc. Reopt.','Local Fetched Bytes exc. Reopt.')

figure;
plot(w_l, (a_rtb + a_rfb)/(10^9),'-ob','MarkerFaceColor','k','Linewidth',2)
hold on;
plot(w_l, a_rtb/(10^9),'--xr','MarkerFaceColor','k','Linewidth',2)
grid on;
xlabel('Window length')
ylabel('Average Fetched Bytes per Request (GB)')
legend('Remote Fetched Bytes inc. Reopt.','Remote Fetched Bytes exc. Reopt.')

figure;
plot(w_l, a_dc,'-x','MarkerFaceColor','k','Linewidth',2)
grid on;
xlabel('Window length')
ylabel('Average Delay per request(s)')

%% Comparioson with other methods 

[avg_rtb,avg_ltb,avg_rfb,avg_lfb,avg_Dc]  = dynamic_optimization(Dataset,'Comparison',quality,req,d,D,C,w_l(7),alpha(4));

figure;
bar([(avg_ltb(1,:)+avg_lfb(1,:))/(10^9); (avg_rtb(1,:)+avg_rfb(1,:))/(10^9)]) 
grid on;
ylabel('Average Fetched Bytes per Request (GB) ')
set(gca,'xticklabel',{'Local','Remote'})
legend('CCA','LFU','LRU','CCA (no collab.)')
