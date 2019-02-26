function [rects] = setRects(origin,wid,params)
% sets stimulus positions

% basic x/y/x/y
pointRect = [origin, origin];

% set various font sizes, relative to screen height
% (this helps accommodate different display resolutions)
scrHeight = origin(2)*2;
rects.txtsize_msg = round(0.05*scrHeight);
rects.txtsize_token = round(0.07*scrHeight);
rects.txtsize_sold = round(0.12*scrHeight);

% position of the token
tokenDiam = 0.22*scrHeight;
tokenCorner = origin - [0.5*tokenDiam, 1*tokenDiam]; % centered above screen center
rects.token = [tokenCorner, tokenCorner + tokenDiam]; % upper-left-most possible position
rects.tokenBorder = rects.token + [-2, -2, 2, 2];

% position of the "SOLD" message
Screen('TextSize',wid,rects.txtsize_sold);
boundRect = Screen('TextBounds',wid,'SOLD');
tokVCen = mean([rects.token(2),rects.token(4)]);
rects.soldY = tokVCen + 0.3*boundRect(4);

% position of time-elapsed scale


% hashX = origin(1) - 200 + floor(rects.timeBarMax*[5,10,15,20,25,90]./100);
% hashY = ones(size(hashX))*(origin(2)-60);
% rects.timeBarHashRects = [hashX; hashY-1; hashX+1; hashY+40];

% vertical position of fixation cross
% rects.fixVertPos = mean([rects.token(4), rects.timeBar(2)])-12; % halfway between

% position of the button
% rects.button = pointRect + [-170, 25, 170, 75]; % just below screen center
% rects.buttonBorder = rects.button + [-3, -3, 3, 3];
% rects.buttonMsgY = origin(2)+38;

% position of point-total message
% (note: these 2 messages are not explicitly centered during each draw 
% because we do not want their position to change when the specific time 
% or point value changes.)
Screen('TextSize',wid,rects.txtsize_msg);
switch params.currency
    case 'money', rects.earningsStr = 'Earned:  $%1.2f';
    case 'points', rects.earningsStr = 'Earned:  %d points';
end
sampleTxt = sprintf(rects.earningsStr,0);
boundRect_points = Screen('TextBounds',wid,sampleTxt);
rects.earningsMsgXY = origin + [-0.5*boundRect_points(3), 0.2*scrHeight];

% ANALOG total-time-left display
Screen('TextSize',wid,rects.txtsize_msg);
rects.timeStr = 'Time left in block:  ';
rects.timeBarMax = 400; % largest amt to be added to 3rd element of timeBar
boundRect_timeleft = Screen('TextBounds',wid,rects.timeStr); 
totalWidth = boundRect_timeleft(3) + 10 + rects.timeBarMax; % total width of the text + margin + graphical bar
rects.timeMsgXY = origin + [-0.5*totalWidth, 0.3*scrHeight]; % center the text + bar
timeStrRightMargin = rects.timeMsgXY(1) + boundRect_timeleft(3);
timeBarYTop = rects.timeMsgXY(2) - 30;
rects.timeBar = [timeStrRightMargin+10, timeBarYTop, timeStrRightMargin+10+rects.timeBarMax, timeBarYTop+30];
rects.timeBarBorder = rects.timeBar + 3*[-1, -1, 1, 1];








