%% Copyright (c) 2020, Mehdi Ghasri
%% To cooperate in articles, send an email to the following address
% (with Subject=CO Article):
% Email: Eng.mehdighasri@gmail.com


%% Copyright (c) 2019, Mehdi Ghasri
% All rights reserved. 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% * Redistributions of source code must retain the above copyright notice, this
%   list of conditions and the following disclaimer.
% 
% * Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution
% * Neither the name of IUPUI nor the names of its
%   contributors may be used to endorse or promote products derived from this
%   software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
function [out,D,lb,ub,Vio] = Func_eng(F)


switch F
    case 1
        out = @PressureVesselDesign;
        D=4;
        lb=[0.0625 0.0625 10 10];
        ub=[99*0.0625 99*0.0625 200 200];
        Vio = [12000 8000 1 1 1];
    case 2
        out = @ThreeBarTruss;
        D=2;
        lb=[0 0];
        ub=[1 1];
        Vio=[140 7 15 1];
    case 3
        out = @GearTrainDesign;
        D=4;
        lb=[12 12 12 12];
        ub=[60 60 60 60];
        Vio = [1 1];
    case 4
        out = @CantileverBeam;
        D=5;
        lb=[0.01 0.01 0.01 0.01 0.01];
        ub=[100 100 100 100 100];
        Vio=[10 1];
    case 5
        out = @WeldedBeam;
        D=4;
        lb=[0.1 0.1 0.1 0.1 ];
        ub=[2 10 10 2 ];
        Vio = [1 1 4 0.001 1 0.5 1 1];
    case 6
        out=@SpeedReducer;
        D=7;
        lb=[2.6, 0.7, 17, 7.3, 7.3, 2.9, 5];
        ub=[3.6, 0.8, 28, 8.3, 8.3, 3.9, 5.5];
        Vio=[50 10 1 1 1 20 1 300 1 1 50 1];
    case 7
        out=@Tensioncompression;
        D=3;
        lb=[0.05,0.25,2.00];
        ub=[2,1.3,15.0];
        Vio=[3 4 0.1 0.1 1];
    case 8
        out=@IBeamDeflection;
        D=4;
        lb=[10 10 0.9 0.9];
        ub=[80 50 5.0 5.0];
        Vio=0.1*[1 1 1];
    case 9
        out=@TubularColumnDesign;
        D=2;
        lb=[2 0.2];
        ub=[14 0.8];
        Vio=[100 1 1 1 1 1 1];
    case 10
        out=@PistonLever;
        D=4;
        lb=[0.05 0.05 0.05 0.05];
        ub=[500 500 500 120];
        Vio=[1 1 1 100 1];
    case 11
        out=@CorrugatedBulkheadDesign;
        D=4;
        lb=[0 0 0 0];
        ub=[100 100 100 5];
        Vio=[1 1 3 3 100 1 1];
    case 12
        out=@CarSideImpactDesign;
        D=11;
        lb = [0.50 0.50 0.50 0.50 0.50 0.50 0.50 0 0 -30 -30];
        ub = [1.50 1.50 1.50 1.50 1.50 1.50 1.50 1 1 +30 +30];
        Vio = [1 1 1 1 1 1 10 29.8 2 6 1];
    case 13
        out = @ConcreteBeamDesign;
        D=3;
        lb=[0 0 5];
        ub=[1 1 10];
        Vio=[50 30 1];
end
end
function out=PressureVesselDesign(x)

y1=x(:,1);%Ts
y2=x(:,2);%Th
y3=x(:,3);%R
y4=x(:,4);%L
%%% opt
fx=0.6224.*y1.*y3.*y4+...
    1.7781.*y2.*y3.^2+...
    3.1661.*y1.^2.*y4+...
    19.84.*y1.^2.*y3;
%%% const
g(:,1)=-y1+0.0193.*y3;
g(:,2)=-y2+0.0095.*y3;
g(:,3)=-pi.*y3.^2.*y4...
    -(4/3).*pi.*y3.^3 ...
    +1296000;
g(:,4)=y4-240;

%%% Penalty
pp=10^15;
for i=1:size(g,1)
    for j=1:size(g,2)
        if g(i,j)>0
            penalty(i,j)=pp.*g(i,j);
        else
            penalty(i,j)=0;
        end
    end
end

out=fx+sum(penalty,2);


end
function out=WeldedBeam(x)
y1=x(:,1);%W
y2=x(:,2);%L
y3=x(:,3);%d
y4=x(:,4);%h
%%% opt
fx=(y2.*1.1047.*y1.^2)+(0.04811.*y3.*y4.*(14+y2));
%%% const
sigm=504000./(y4.*y3.^2);
q=6000*(14+(y2./2));
D=0.5.*((y2.^2)+(y1+y3).^2).^0.5;
j=2*sqrt(2).*y1.*y2.*((y2.^2./6)+((y1+y3).^2)./2);
delta=65856./(30000.*y4.*y3.^3);
beta=(q.*D)./j;
alfa=6000./(sqrt(2).*y1.*y2);
toa=(alfa.^2+beta.^2+(alfa.*beta.*y2)./D).^0.5;
p=(0.61423*10^6).*((y3.*y4.^3)./6).*(1-(y3.*sqrt(y4.^6.*30/48))./28);

g(:,1)=toa-13600;
g(:,2)=sigm-30000;
g(:,3)=y1-y4;
g(:,4)=(0.1047.*y1.^2.*y2)+(0.04811.*y4.*y3.*(14+y2))-5;
g(:,5)=0.125-y1;
g(:,6)=delta-0.25;
g(:,7)=6000-p;
pp=10^15;
for i=1:size(g,1)
    for j=1:size(g,2)
        if g(i,j)>0
            penalty(i,j)=pp.*g(i,j);
        else
            penalty(i,j)=0;
        end
    end
end

out=fx+sum(penalty,2);

end

function out=StringDesign(x)

y1=x(:,1);%W
y2=x(:,2);%d
y3=x(:,3);%N
%%% opt
fx=(y3+2).*y2.*y1.^2;
%%% const
g(:,1)=1-(y2.^3.*y3)./(71785.*y1.^4);
g(:,2)=(4.*y2.^2-y1.*y2)./...
    (12566.*(y2.*y1.^3-y1.^4))...
    +(1./(5108.*y1.^2))-1;
g(:,3)=1-(140.45.*y1./(y2.^2.*y3));
g(:,4)=(y1+y2)./1.5-1;
%%% Penalty
pp=10^15;
for i=1:size(g,1)
    for j=1:size(g,2)
        if g(i,j)>0
            penalty(i,j)=pp.*g(i,j);
        else
            penalty(i,j)=0;
        end
    end
end

out=fx+sum(penalty,2);

end
function out=ThreeBarTruss(x)

A1=x(:,1);
A2=x(:,2);
%%%opt
fx=(2*sqrt(2).*A1+A2).*100;
%%% const
g(:,1)=2.*(sqrt(2).*A1+A2)./...
    (sqrt(2).*A1.^2+2.*A1.*A2)-2;
g(:,2)=2.*A2./(sqrt(2).*A1.^2+...
    2.*A1.*A2)-2;
g(:,3)=2./(A1+sqrt(2).*A2)-2;
%%% Penalty
pp=10^15;
for i=1:size(g,1)
    for j=1:size(g,2)
        if g(i,j)>0
            penalty(i,j)=pp.*g(i,j);
        else
            penalty(i,j)=0;
        end
    end
end

out=fx+sum(penalty,2);

end
function out=GearTrainDesign(x)

y1=x(:,1);%A
y2=x(:,2);%B
y3=x(:,3);%C
y4=x(:,4);%D
%%% opt
fx=((1/6.931)-((y1.*y2)./(y3.*y4))).^2;
out=fx;
end
function out=CantileverBeam(x)
y1=x(:,1);%1
y2=x(:,2);%2
y3=x(:,3);%3
y4=x(:,4);%4
y5=x(:,5);%5
%%% opt
fx=0.0624.*(y1+y2+y3+y4+y5);
%%%% const
g(:,1)=(61./y1.^3)+(37./y2.^3)+(19./y3.^3)+(7./y4.^3)+(1./y5.^3)-1;
%%% Penalty
pp=10^15;
for i=1:size(g,1)
    for j=1:size(g,2)
        if g(i,j)>0
            penalty(i,j)=pp.*g(i,j);
        else
            penalty(i,j)=0;
        end
    end
end

out=fx+sum(penalty,2);

end

function out=SpeedReducer(x)
% Weight Minimization of a Speed Reducer
fx = 0.7854*x(:,1).*x(:,2).^2.*(3.3333.*x(:,3).^2+14.9334.*x(:,3)-43.0934)-1.508.*x(:,1).*(x(:,6).^2+x(:,7).^2).....
    +7.477.*(x(:,6).^3+x(:,7).^3)+0.7854.*(x(:,4).*x(:,6).^2+x(:,5).*x(:,7).^2);
g(:,1) = -x(:,1).*x(:,2).^2.*x(:,3)+27;
g(:,2) = -x(:,1).*x(:,2).^2.*x(:,3).^2+397.5;
g(:,3) = -x(:,2).*x(:,6).^4.*x(:,3).*x(:,4).^(-3)+1.93;
g(:,4) = -x(:,2).*x(:,7).^4.*x(:,3)./x(:,5).^3+1.93;
g(:,5) = 10.*x(:,6).^(-3).*sqrt(16.91.*10^6+(745.*x(:,4)./(x(:,2).*x(:,3))).^2)-1100;
g(:,6) = 10.*x(:,7).^(-3).*sqrt(157.5.*10^6+(745.*x(:,5)./(x(:,2).*x(:,3))).^2)-850;
g(:,7) = x(:,2).*x(:,3)-40;
g(:,8) = -x(:,1)./x(:,2)+5;
g(:,9) = x(:,1)./x(:,2)-12;
g(:,10) = 1.5.*x(:,6)-x(:,4)+1.9;
g(:,11) = 1.1.*x(:,7)-x(:,5)+1.9;
pp=10^15;
for i=1:size(g,1)
    for j=1:size(g,2)
        if g(i,j)>0
            penalty(i,j)=pp.*g(i,j);
        else
            penalty(i,j)=0;
        end
    end
end
out=fx+sum(penalty,2);
end

function out=Tensioncompression(x)
fx = x(:,1).^2.*x(:,2).*(x(:,3)+2);
g(:,1) = 1-(x(:,2).^3.*x(:,3))./(71785.*x(:,1).^4);
g(:,2) = (4.*x(:,2).^2-x(:,1).*x(:,2))./(12566.*(x(:,2).*x(:,1).^3-x(:,1).^4))....
    + 1./(5108.*x(:,1).^2)-1;
g(:,3) = 1-140.45.*x(:,1)./(x(:,2).^2.*x(:,3));
g(:,4) = (x(:,1)+x(:,2))./1.5-1;
pp=10^15;
for i=1:size(g,1)
    for j=1:size(g,2)
        if g(i,j)>0
            penalty(i,j)=pp.*g(i,j);
        else
            penalty(i,j)=0;
        end
    end
end
out=fx+sum(penalty,2);
end

function out=IBeamDeflection(x)
term1 = x(3)*(x(1)-2*x(4))^3/12; term2 = x(2)*x(4)^3/6; term3 = 2*x(2)*x(4)*((x(1)-x(4))/2)^2;
fx = 5000/(term1+term2+term3);
g(1) = 2*x(2)*x(4)+x(3)*(x(1)-2*x(4))-300;
term1 = x(3)*(x(1)-2*x(4))^3;
term2 = 2*x(2)*x(4)*(4*x(4)^2+3*x(1)*(x(1)-2*x(4)));
term3 = (x(1)-2*x(4))*x(3)^3;
term4 = 2*x(4)*x(2)^3;
g(2) = ((18*x(1)*10^4)/(term1+term2))+((15*x(2)*10^3)/(term3+term4))-6;
pp=10^15;
for i=1:size(g,1)
    for j=1:size(g,2)
        if g(i,j)>0
            penalty(i,j)=pp.*g(i,j);
        else
            penalty(i,j)=0;
        end
    end
end
out=fx+sum(penalty,2);
end

function out=TubularColumnDesign(x)
fx = 9.8*x(1)*x(2)+2*x(1);
g(1)=1.59-x(1)*x(2);
g(2)=47.4-x(1)*x(2)*(x(1)^2+x(2)^2);
g(3)=2/x(1)-1;
g(4)=x(1)/14-1;
g(5)=2/x(1)-1;
g(6)=x(1)/8-1;
pp=10^15;
for i=1:size(g,1)
    for j=1:size(g,2)
        if g(i,j)>0
            penalty(i,j)=pp.*g(i,j);
        else
            penalty(i,j)=0;
        end
    end
end
out=fx+sum(penalty,2);
end

function out=PistonLever(x)
teta = 0.25*pi; H=x(1); B=x(2); D=x(3); X=x(4);
l2=((X*sin(teta)+H)^2+(B-X*cos(teta))^2)^0.5;
l1=((X-B)^2+H^2)^0.5;
fx=0.25*pi*D^2*(l2-l1);
teta = 0.25*pi; H=x(1); B=x(2); D=x(3); X=x(4); P=1500; Q=10000; L=240; Mmax=1.8e+6;
R=abs(-X*(X*sin(teta)+H)+H*(B-X*cos(teta)))/sqrt((X-B)^2+H^2);
F=0.25*pi*P*D^2;
l2=((X*sin(teta)+H)^2+(B-X*cos(teta))^2)^0.5;
l1=((X-B)^2+H^2)^0.5;
g(1)=Q*L*cos(teta)-R*F;
g(2)=Q*(L-X)-Mmax;
g(3)=1.2*(l2-l1)-l1;
g(4)=0.5*D-B;
pp=10^15;
for i=1:size(g,1)
    for j=1:size(g,2)
        if g(i,j)>0
            penalty(i,j)=pp.*g(i,j);
        else
            penalty(i,j)=0;
        end
    end
end
out=fx+sum(penalty,2);
end

function out=CorrugatedBulkheadDesign(x)
b=x(1); h=x(2); l=x(3); t=x(4); ABD = abs(l^2-h^2);
fx = (5.885*t*(b+l))/(b+(abs(l^2-h^2))^0.5);
g(1)=-t*h*(0.4*b+l/6)+8.94*(b+(ABD)^0.5);
g(2)=-t*h^2*(0.2*b+l/12)+2.2*(8.94*(b+(ABD)^0.5))^(4/3);
g(3)=-t+0.0156*b+0.15;
g(4)=-t+0.0156*l+0.15;
g(5)=-t+1.05;
g(6)=-l+h;
pp=10^15;
for i=1:size(g,1)
    for j=1:size(g,2)
        if g(i,j)>0
            penalty(i,j)=pp.*g(i,j);
        else
            penalty(i,j)=0;
        end
    end
end
out=fx+sum(penalty,2);
end

function out=CarSideImpactDesign(x)
% Sections
Sec8 = [0.192 0.345];
Sec9 = [0.192 0.345];
nSec8 = numel(Sec8);
nSec9 = numel(Sec9);
x(8) = Sec8(min(floor(x(8)*nSec8+1),nSec8));
x(9) = Sec8(min(floor(x(9)*nSec9+1),nSec9));

% Objective
fx=1.98+4.90*x(1)+6.67*x(2)+6.98*x(3)+4.01*x(4)+1.78*x(5)+2.73*x(7);

% Subjective
Fa =1.16-0.3717*x(2)*x(4)-0.00931*x(2)*x(10)-0.484*x(3)*x(9)+0.01343*x(6)*x(10);
VCu =0.261-0.0159*x(1)*x(2)-0.188*x(1)*x(8)-0.019*x(2)*x(7)+0.0144*x(3)*x(5)+0.0008757*x(5)*x(10)+0.08045*x(6)*x(9)+0.00139*x(8)*x(11)+0.00001575*x(10)*x(11);
VCm =0.214+0.00817*x(5)-0.131*x(1)*x(8)-0.0704*x(1)*x(9)+0.03099*x(2)*x(6)-0.018*x(2)*x(7)+0.0208*x(3)*x(8)+0.121*x(3)*x(9)-0.00364*x(5)*x(6)+0.0007715*x(5)*x(10)-0.0005354*x(6)*x(10)+0.00121*x(8)*x(11)+0.00184*x(9)*x(10)-0.02*x(2)^2;
VCl=0.74-0.61*x(2)-0.163*x(3)*x(8)+0.001232*x(3)*x(10)-0.166*x(7)*x(9)+0.227*x(2)^(2);
Dur=28.98+3.818*x(3)-4.2*x(1)*x(2)+0.0207*x(5)*x(10)+6.63*x(6)*x(9)-7.7*x(7)*x(8)+0.32*x(9)*x(10);
Dmr=33.86+2.95*x(3)+0.1792*x(10)-5.057*x(1)*x(2)-11*x(2)*x(8)-0.0215*x(5)*x(10)-9.98*x(7)*x(8)+22*x(8)*x(9);
Dlr=46.36-9.9*x(2)-12.9*x(1)*x(8)+0.1107*x(3)*x(10);
Fp=4.72-0.5*x(4)-0.19*x(2)*x(3)-0.0122*x(4)*x(10)+0.009325*x(6)*x(10)+0.000191*x(11)^(2);
VMBP=10.58-0.674*x(1)*x(2)-1.95*x(2)*x(8)+0.02054*x(3)*x(10)-0.0198*x(4)*x(10)+0.028*x(6)*x(10);
VFD=16.45-0.489*x(3)*x(7)-0.843*x(5)*x(6)+0.0432*x(9)*x(10)-0.0556*x(9)*x(11)-0.000786*x(11)^(2);
g = [Fa-1, VCu-0.32, VCm-0.32, VCl-0.32, Dur-32, Dmr-32, Dlr-32, Fp-4, VMBP-9.9, VFD-15.7];
pp=10^15;
for i=1:size(g,1)
    for j=1:size(g,2)
        if g(i,j)>0
            penalty(i,j)=pp.*g(i,j);
        else
            penalty(i,j)=0;
        end
    end
end
out=fx+sum(penalty,2);
end

function out=ConcreteBeamDesign(x)
x1 = [6 6.16 6.32 6.6 7 7.11 7.2 7.8 7.9 8 8.4];
nx1 = numel(x1);
x2 = 28:40;
nx2 = numel(x2);

As = x1(min(floor(x(1)*nx1+1),nx1));
b = x2(min(floor(x(2)*nx2+1),nx2));
h = x(3);

% Objective
fx=29.4*As+0.6*b*h;

% Subjectives
g(1)=b/h-4;
g(2)=180+7.375*As^2/h-As*b;
pp=10^15;
for i=1:size(g,1)
    for j=1:size(g,2)
        if g(i,j)>0
            penalty(i,j)=pp.*g(i,j);
        else
            penalty(i,j)=0;
        end
    end
end
out=fx+sum(penalty,2);
end