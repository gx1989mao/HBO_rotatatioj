clear;clc;

load("rotation_HBO.mat");
load("sig_emd.mat");
sig = rotation_HBO*1e3;
shift = 500;
for ch=1:48
    for s=1:24
        sig(ch,:,s) = sig(ch,:,s)-sig(ch,shift,s);
    end
end

DPCR = [1,2,3,17,18,4,5,6,7,8];
DPCL = [35,34,33,20,19,40,39,38,37,36];
VPCR = [9,10,11,12,13,14,15,16];
VPCL = [45,44,43,42,41,48,47,46];
FCR = [21,22,25,26,29,30];
FCL = [24,23,28,27,32,31];
channel_map = {DPCR,DPCL,VPCR,VPCL,FCR,FCL};

%% emd proc
sig_emd = sig(:,shift:1000,:);
Fs = 8.2;
for s=1:24
    disp(s);
    for ch=1:48
        imf0=pEMDandFFT(sig_emd(ch,:,s),Fs);close;
        if ~isempty(imf0)
            sig_emd(ch,:,s) = sig_emd(ch,:,s)-imf0(1,:);
        end
    end
end
%%
shift = 1;
for ch=1:48
    for s=1:24
        sig_emd(ch,:,s) = sig_emd(ch,:,s)-sig_emd(ch,shift,s);
    end
end

%%  1 7. 9 19 20.
figure(1);
s = 9;
for i=1:6
    subplot(3,2,i);
    map = channel_map{i};
    for ch = 1:size(map,2)
        if map(ch)~=45 && map(ch)~=43 && map(ch)~=41
            plot(sig_emd(map(ch),:,s));hold on;
        end
    end
    axis([0 500 -5 10]);
end

%% topograph draw
clf;
figure(1);
z =channels(:,1);
[xi,yi] = meshgrid(0:0.02:15,0:0.02:5);
zi=griddata(x,y,z,xi,yi,'v4');
% zi(xi.^2+yi.^2>R^2)=nan;
contourf(xi,yi,zi,20,'LineWidth',0.01); hold on;
plot(x,y,'k.');
% caxis([0 2]);  % 颜色显示范围设定 重要！
axis off;
set(gcf,'unit','normalized','position',[0.2,0.2,0.64,0.32]);

figure(2);
z =channels(:,2);
[xi,yi] = meshgrid(0:0.02:15,0:0.02:5);
zi=griddata(x,y,z,xi,yi,'v4');
% zi(xi.^2+yi.^2>R^2)=nan;
contourf(xi,yi,zi,20,'LineWidth',0.01); hold on;
plot(x,y,'k.');
axis off;
set(gcf,'unit','normalized','position',[0.2,0.2,0.64,0.32]);


%%
function [E,F] = eta2(X,Y)
total = [X;Y];
M = mean(total);
sb = (mean(X)-M)^2 *length(X) + (mean(Y)-M)^2 *length(Y);
st = std(total)^2*length(total);
sw = std(X)^2*length(X) + std(Y)^2*length(Y);

E = sb/(st+sb);
F = sb/(sw/(length(total)-2));

end

