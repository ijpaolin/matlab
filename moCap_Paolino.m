% Isaac Paolino
% ijpaolin@ncsu.edu
% 11/28/2023
% moCap_Paolino.m
%
% Tracks motion of body parts using leds and color thresholding

clear
close all
clc

%% Declarations
% You will probably add many more variables to this section. Remember:
% avoid numbers in later sections of your code, so include parameters
% like threshold limits, crop values, etc., in this section.

% Constant
G = -9.81; % gravity (m/s^2)

% Ball properties
personMass = 0.03;    % ball mass (kg)
LEDin = 4;        % ball diameter (in)
LEDDPx = 290-122; % ball diameter (px) CHANGE THIS
px2in = LEDDPx/LEDin;
px2m = 1; % pixel to meter conversion factor CHANGE THIS

% Video information
vidFile = 'walkVid.mov'; % with extension

% Load video
vid = VideoReader(vidFile);    % reads in .avi file
% More video information
videoRate = vid.FrameRate; % Default is 30 fps
timeStart = 4.2; % start time (s)
timeStop = 6.2;% stop time (s)
frameStart = ceil(timeStart*videoRate); % starting frame
frameStop = floor(timeStop*videoRate); % stopping frame

% Thresholding Red LED
RrLTH = 220; % red lower threshold
RgUTH = 45; % green upper threshold
RbUTH = 100; % blue upper threshold

% Thresholding Green LED
GrUTH = 40; % red upper threshold
GgLTH = 210; % green lower threshold
GbUTH = 200; % blue upper threshold

% Thresholding Cyan LED
CrUTH = 40; % red upper threshold
CgUTH = 230; % green upper threshold
CbLTH = 200; % blue lower threshold

% Thresholding Yellow LED
YrLTH = 190;
YgLTH = 190;
YbUTH = 90;

desiredFrameRate = 30; % frames in fps

% Crop values
xCrop = 100; % x value starting position for crop (px)
delX = 1600; % delta x (px)

yCrop = 400; % y value starting position for crop (px)
delY = 600; % delta y (px)

% Loop Counter
i = 1;

vidObj = VideoWriter('NajiVid');
vidObj.FrameRate = desiredFrameRate; % set frame rate (e.g., 15)
open(vidObj) % opens video for recording

vidObj2 = VideoWriter('NajiVid2');
vidObj2.FrameRate = desiredFrameRate; % set frame rate (e.g., 15)
open(vidObj2) % opens video for recording

%% Threshold Video

% Step through each frame
for k = frameStart:frameStop

    frameSlice = read(vid,k); % loads current frame into frameSlice
    % Crop image
    croppedImg = imcrop(frameSlice,[xCrop,yCrop,delX,delY]);

    % Threshold
    red = croppedImg(:,:,1);
    green = croppedImg(:,:,2);
    blue = croppedImg(:,:,3);

    imgGray = im2gray(croppedImg);
    imgBin = im2bw(imgGray); %#ok<IM2BW>
    %     imgBin(red>=rLTH & green<= gUTH & blue <= bUTH) = 1;
    %     imgBin(~(red>=rLTH & green<= gUTH & blue <= bUTH)) = 0;

    imgBinRed = imgBin;
    imgBinRed(red>=RrLTH & blue <= RbUTH & green<= RgUTH) = 1;
    imgBinRed(~(red>=RrLTH & blue <= RbUTH & green<= RgUTH)) = 0;


    imgBinGreen = imgBin;
    imgBinGreen(red<=GrUTH & blue <= GbUTH & green>= GgLTH) = 1;
    imgBinGreen(~(red<=GrUTH & blue <= GbUTH & green>= GgLTH)) = 0;


    imgBinCyan = imgBin;
    imgBinCyan(red<=CrUTH & blue >= CbLTH & green<= CgUTH) = 1;
    imgBinCyan(~(red<=CrUTH & blue >= CbLTH & green<= CgUTH)) = 0;


    imgBinYellow = imgBin;
    imgBinYellow(red>=YrLTH & blue <= YbUTH & green>= YgLTH) = 1;
    imgBinYellow(~(red>=YrLTH & blue <= YbUTH & green>= YgLTH)) = 0;

    imgBin2 = imgBin;
    imgBin2(imgBinRed == 1 | imgBinGreen == 1 | imgBinCyan == 1 | imgBinYellow == 1) = 1;
    imgBin2(~(imgBinRed == 1 | imgBinGreen == 1 | imgBinCyan == 1 | imgBinYellow == 1)) = 0;


    subplot(3,1,1)
    %imshowpair(imgBin,croppedImg,'montage')
    imshow(croppedImg)
    title('Color Cropped Image')

    subplot(3,1,2)
    imshow(imgBin2)
    %imshow(imgBinCyan)
    title('Thresholded Image')


    [rMax,cMax]=size(imgBin);
    [RrCent(i), RcCent(i)] = Centroid(imgBinRed); %#ok<SAGROW>
    [GrCent(i), GcCent(i)] = Centroid(imgBinGreen); %#ok<SAGROW>
    [CrCent(i), CcCent(i)] = Centroid(imgBinCyan); %#ok<SAGROW>
    [YrCent(i), YcCent(i)] = Centroid(imgBinYellow); %#ok<SAGROW>


    subplot(3,1,3)
    plot(RcCent/px2m,(rMax-RrCent)/px2m,'r', LineWidth=2)
    hold on
    plot(RcCent(i)/px2m,(rMax-RrCent(i))/px2m,'rx',LineWidth=2)
    hold on

    plot(GcCent/px2m,(rMax-GrCent)/px2m,'g', LineWidth=2)
    hold on
    plot(GcCent(i)/px2m,(rMax-GrCent(i))/px2m,'gx', LineWidth=2)
    hold on

    plot(CcCent/px2m,(rMax-CrCent)/px2m,'c', LineWidth=2)
    hold on
    plot(CcCent(i)/px2m,(rMax-CrCent(i))/px2m,'cx', LineWidth=2)
    hold on

    plot(YcCent/px2m,(rMax-YrCent)/px2m,'y', LineWidth=2)
    hold on
    plot(YcCent(i)/px2m,(rMax-YrCent(i))/px2m,'yx', LineWidth=2)
    hold off

    set(gca,'xtick',[])
    set(gca,'xticklabel',[])
    set(gca,'ytick',[])
    set(gca,'yticklabel',[])

    xlim([0,cMax/px2m]);
    ylim([0,rMax/px2m]);
    pbaspect([1,rMax/cMax,1])
    title('Position of Joint Centroids over Time')
    xlabel('X Position (pixles)')
    ylabel('Y Position (pixles)')


    % Display the thresholded image and plot centroid movement dynamically
    % Make sure image and plot are same size, and no change in axes from
    % plot to plot

    %pause
    timeTot(i) = i/videoRate; %#ok<SAGROW>
    i = i+1;
    drawnow % forces figure to appear, which may not happen in loops

    frame = getframe(gcf); % saves plot in variable frame
    writeVideo(vidObj,frame); % writes frame to video
end
%timeTot(1:frameStart-1)=[];

xRed = RcCent/px2m;
xGreen = GcCent/px2m;
xCyan = CcCent/px2m;
xYellow = YcCent/px2m;


yRed = (rMax-RrCent)/px2m;
yGreen = (rMax-GrCent)/px2m;
yCyan = (rMax-CrCent)/px2m;
yYellow = (rMax-YrCent)/px2m;

vxRed = gradient(xRed,timeTot);
vxGreen = gradient(xGreen,timeTot);
vxCyan = gradient(xCyan,timeTot);
vxYellow = gradient(xYellow,timeTot);

vyRed = gradient(yRed,timeTot);
vyGreen = gradient(yGreen,timeTot);
vyCyan = gradient(yCyan,timeTot);
vyYellow = gradient(yYellow,timeTot);


%% Stick Figure

i=1; % loop counter reset
for k = frameStart:frameStop

    frameSlice = read(vid,k); % loads current frame into frameSlice
    % Crop image
    figure(2)
    subplot(2,1,1)
    croppedImg2 = imcrop(frameSlice,[xCrop,yCrop,delX,delY]);
    imshow(croppedImg2)
    title('Color Cropped Image')

    subplot(2,1,2)
    plot([RcCent(i)/px2m,GcCent(i)/px2m],[(rMax-RrCent(i))/px2m,(rMax-GrCent(i))/px2m],'r',...
        [GcCent(i)/px2m,CcCent(i)/px2m],[(rMax-GrCent(i))/px2m,(rMax-CrCent(i))/px2m],'g',...
        [CcCent(i)/px2m,YcCent(i)/px2m],[(rMax-CrCent(i))/px2m,(rMax-YrCent(i))/px2m],'c')
    hold on

    plot(RcCent(i)/px2m,(rMax-RrCent(i))/px2m,'r.', GcCent(i)/px2m,(rMax-GrCent(i))/px2m,'g.',...
        CcCent(i)/px2m,(rMax-CrCent(i))/px2m,'c.',YcCent(i)/px2m,(rMax-YrCent(i))/px2m,'y.', MarkerSize = 30)
    hold on
%     quiver([RcCent(i)/px2m,GcCent(i)/px2m,CcCent(i)/px2m,YcCent(i)/px2m],...
%         [(rMax-RrCent(i))/px2m,(rMax-GrCent(i))/px2m,...
%         (rMax-CrCent(i))/px2m,(rMax-YrCent(i))/px2m],[vxRed(i),vxGreen(i),vxCyan(i),vxYellow(i)],...
%         [vyRed(i),vyGreen(i),vyCyan(i),vyYellow(i)],'r')
%     hold on
    quiver(GcCent(i)/px2m,(rMax-GrCent(i))/px2m,vxGreen(i),vyGreen(i),0.1,'g', LineWidth = 3, MaxHeadSize=3)
    hold on
    quiver(CcCent(i)/px2m,(rMax-CrCent(i))/px2m,vxCyan(i),vyCyan(i),0.1,'c', LineWidth=3, MaxHeadSize=3)
    hold on
    quiver(YcCent(i)/px2m,(rMax-YrCent(i))/px2m,vxYellow(i),vyYellow(i),0.1,'y', LineWidth=2, MaxHeadSize=3)
    hold on
    quiver(RcCent(i)/px2m,(rMax-RrCent(i))/px2m,vxRed(i),vyRed(i),0.1,'r', LineWidth=2, MaxHeadSize=3)
    hold off

    xlim([0,cMax/px2m]);
    ylim([0,rMax/px2m]);
    pbaspect([1,rMax/cMax,1])
    title('Position and Velocity of Joint Centroids over Time')
    xlabel('X Position (pixels)')
    ylabel('Y Position (pixels)')
    set(gca,'xtick',[])
    set(gca,'xticklabel',[])
    set(gca,'ytick',[])
    set(gca,'yticklabel',[])

    i = i+1;
    frame = getframe(gcf); % saves plot in variable frame
    writeVideo(vidObj2,frame); % writes frame to video
end
close(vidObj)
close(vidObj2)
