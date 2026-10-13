classdef RodentTracker < matlab.apps.App

    % Used to locate and load the app's XML configuration file
    properties (Access = public, Constant)
        AppConfigFilename = './RodentTracker.xml'; % File path to the app configuration file containing component layout and settings
    end

    % Properties that correspond to app components
    properties (Access = public)
        RodentTrackerUIFigure           matlab.ui.Figure
        FileMenu                        matlab.ui.container.Menu
        LoadVideoMenu                   matlab.ui.container.Menu
        AnalyzeMenu                     matlab.ui.container.Menu
        EditMenu                        matlab.ui.container.Menu
        TraceMenu                       matlab.ui.container.Menu
        TraceColorMenu                  matlab.ui.container.Menu
        ClearTraceMenu                  matlab.ui.container.Menu
        AnalysisPreviewMenu             matlab.ui.container.Menu
        EllipseMenu                     matlab.ui.container.Menu
        EllipseColorMenu                matlab.ui.container.Menu
        CentroidMenu                    matlab.ui.container.Menu
        CentroidColorMenu               matlab.ui.container.Menu
        TailpointMenu                   matlab.ui.container.Menu
        TailColorMenu                   matlab.ui.container.Menu
        HeadpointMenu                   matlab.ui.container.Menu
        HeadColorMenu                   matlab.ui.container.Menu
        ViewMenu                        matlab.ui.container.Menu
        VideoWindowMenu                 matlab.ui.container.Menu
        TraceWindowMenu                 matlab.ui.container.Menu
        ROISelectorMenu                 matlab.ui.container.Menu
        ResultsMenu                     matlab.ui.container.Menu
        MainSpreadsheetMenu             matlab.ui.container.Menu
        ROIresultsMenu                  matlab.ui.container.Menu
        VideoBackgroundLastframeMenu    matlab.ui.container.Menu
        ValidationMenu                  matlab.ui.container.Menu
        SAPMenu                         matlab.ui.container.Menu
        GridLayout                      matlab.ui.container.GridLayout
        StructuralElementSizeSlider     matlab.ui.control.Slider
        StructuralElementSizeLabel      matlab.ui.control.Label
        TimeSlider                      matlab.ui.control.Slider
        TimeSliderLabel                 matlab.ui.control.Label
        BackgroundButtonGroup           matlab.ui.container.ButtonGroup
        LightButton                     matlab.ui.control.RadioButton
        DarkButton                      matlab.ui.control.RadioButton
        ResetButton                     matlab.ui.control.Button
        RightArrowSEThresholdSlider     matlab.ui.control.Button
        RightArrowBinaryThresholdSlider  matlab.ui.control.Button
        LeftArrowBinaryThresholdSlider  matlab.ui.control.Button
        LeftArrowSEThresholdSlider      matlab.ui.control.Button
        RightArrowTimeSlider            matlab.ui.control.Button
        LeftArrowTimeSlider             matlab.ui.control.Button
        PlayButton                      matlab.ui.control.Button
        FileInfoText                    matlab.ui.control.Label
        ClearTraceButton                matlab.ui.control.Button
        BinaryThresholdSlider           matlab.ui.control.Slider
        VideoFileLabel                  matlab.ui.control.Label
        LoadVideoButton                 matlab.ui.control.Button
        DropDown                        matlab.ui.control.DropDown
        AnalyzeButton                   matlab.ui.control.Button
        BinaryThresholdEditField        matlab.ui.control.NumericEditField
        TimesEditField                  matlab.ui.control.NumericEditField
        SEThresholdEditField            matlab.ui.control.NumericEditField
        ProgressText                    matlab.ui.control.Label
        BinaryThresholdLabel            matlab.ui.control.Label
    end

    
    properties (Access = public)
        filename
        folder
        Image
        Background_Image
        Image_info
        fps
        Video_Window
        Spreadsheet_Window
        Background_Window = RodentTracker_Background_Window;
        Trace_Window
        real_width
        real_height
        real_units
        t
        t2
        TraceColor = 'w';
        EllipseColor = 'r';
        CentroidColor = 'g';
        TailpointColor = 'b';
        HeadpointColor = 'c';
        start = 1;
        ROI
        ROI_Raw
        ROI_Binary
        ROI_NoTail
        ROI_Ellipse
        ROI_Position
        ROI_Raw_Position
        ROI_Binary_Position
        ROI_NoTail_Position
        ROI_Ellipse_Position
        SAP_Window
        Eccentricity
        Speed
        SAPDetection
        ROI_coord
        ROI_Data
        ROI_Results_Window
        ROIResultsFileMenu
        ROIResultsSaveasMenu
    end
    
    methods (Access = public)
        
        function OpenTiffImage(app)
            
            % If TIFF
                files = dir(fullfile(app.folder,'*.tif'));
                app.DropDown.Items = {files.name};
                app.DropDown.Value = app.filename;
                pixel_width = app.Image_info(1).Width;
                pixel_height = app.Image_info(1).Height;


                app.Trace_Window.RodentTrackerTraceUIFigure.Visible ="on";

                app.Trace_Window.UIAxes.XLim = [0 app.Image_info(1).Width];
                app.Trace_Window.UIAxes.YLim = [0 app.Image_info(1).Height];

                if isempty(app.Image_info(1).XResolution) || isempty(app.fps)
                    real_dim = inputdlg({'Enter image/frame width:','Enter image/frame name:','Units:','FPS:'},'Frame Dimensions',[1 60],{'30','30','cm','10'});
                    real_width_TIFF = str2double(real_dim{1});
                    real_height_TIFF = str2double(real_dim{2});
                    real_units_TIFF = real_dim{3};
                    app.fps = str2double(real_dim{4});
                    app.Image_info(1).XResolution = real_width_TIFF;
                    app.Image_info(1).YResolution = real_height_TIFF;
                    app.Image_info(1).ResolutionUnit = real_units_TIFF;
                else
                    real_width_TIFF = app.Image_info(1).XResolution;
                    real_height_TIFF = app.Image_info(1).YResolution;
                    real_units_TIFF = app.Image_info(1).ResolutionUnit;
                end

                app.TimeSlider.Limits(2) = length(app.Image_info)/app.fps;

                app.ProgressText.Text = 'Loading...';
                app.ProgressText.Visible = "on";

                app.FileInfoText.Text = {['FPS: ' num2str(app.fps)];['width: ' num2str(real_width_TIFF) ' ' real_units_TIFF];['height: ' num2str(real_height_TIFF) ' ' real_units_TIFF]};
                app.FileInfoText.Visible = "on";

                i = floor(app.TimeSlider.Value*app.fps+1);

                % preallocate
                app.Speed = zeros(size(app.Image_info,1)-1,1);
                app.Eccentricity = zeros(size(app.Image_info,1)-1,1);
                xdistcoord = zeros(size(app.Image_info,1)-1,1);
                ydistcoord = zeros(size(app.Image_info,1)-1,1);
                Orientation = zeros(size(app.Image_info,1)-1,1);
                MajorAxisLength = zeros(size(app.Image_info,1)-1,1);
                MinorAxisLength = zeros(size(app.Image_info,1)-1,1);
                Area = zeros(size(app.Image_info,1)-1,1);

                if size(size(app.Background_Image),2) == 3
                    % Convert to Binary Image

                     if isfloat(app.Image)

                        if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                            bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < app.BinaryThresholdSlider.Value);
                        else
                            bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) > app.BinaryThresholdSlider.Value;
                        end
                    else
                        if isa(app.Background_Image,'uint8')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < 255*app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < 255*app.BinaryThresholdSlider.Value);
                            else
                                bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) >= 255*app.BinaryThresholdSlider.Value;
                            end

                        end
                        if isa(app.Background_Image,'uint16')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < 65535*app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < 65535*app.BinaryThresholdSlider.Value);
                            else
                                bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) >= 65535*app.BinaryThresholdSlider.Value;
                            end
                        end
                     end

                    % Display Images

                    % Raw Image

                    app.Video_Window.RodentTrackerAnalysisPreviewUIFigure.Visible ="on";

                    imshow(app.Image(:,:,:,i),'Parent',app.Video_Window.RawAxes)
                    title(app.Video_Window.RawAxes,'Original Video')
                    % Binary Image

                    imshow(bw_display_image,'Parent',app.Video_Window.BinaryAxes)
                    title(app.Video_Window.BinaryAxes,'Binary Video')
                   
                else
                    % GRAYSCALE TIFF

                    % Convert to Binary Image

                             if isfloat(app.Image)

                        if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                            bw_display_image = (app.Image(:,:,i)<app.BinaryThresholdSlider.Value)-(app.Background_Image<app.BinaryThresholdSlider.Value);
                        else
                            bw_display_image = app.Image(:,:,i)-app.Background_Image > app.BinaryThresholdSlider.Value;
                        end
                    else
                        if isa(app.Background_Image,'uint8')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (app.Image(:,:,i)<= 255*app.BinaryThresholdSlider.Value)-(app.Background_Image<= 255*app.BinaryThresholdSlider.Value);
                            else
                                bw_display_image = app.Image(:,:,i)-app.Background_Image >= 255*app.BinaryThresholdSlider.Value;
                            end

                        end
                        if isa(app.Background_Image,'uint16')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (app.Image(:,:,i)<= 65535*app.BinaryThresholdSlider.Value)-(app.Background_Image<= 65535*app.BinaryThresholdSlider.Value);
                            else
                                bw_display_image = app.Image(:,:,i)-app.Background_Image >= 65535*app.BinaryThresholdSlider.Value;
                            end
                        end
                             end

                    % Raw Image

                    app.Video_Window.RodentTrackerAnalysisPreviewUIFigure.Visible ="on";

                    imshow(app.Image(:,:,i),'Parent',app.Video_Window.RawAxes)
                    title(app.Video_Window.RawAxes,'Original Video')
                    % Binary Image

                    imshow(bw_display_image,'Parent',app.Video_Window.BinaryAxes)
                    title(app.Video_Window.BinaryAxes,'Binary Video')
                   
                end

                 % Remove tail
                    se = strel('disk',round(app.StructuralElementSizeSlider.Value));

                    imshow(imopen(bw_display_image,se),'Parent',app.Video_Window.NoTailAxes)
                    title(app.Video_Window.NoTailAxes,'Remove Tail')

                    rp = regionprops(bw_display_image,'Orientation', 'MajorAxisLength', ...
                        'MinorAxisLength', 'Eccentricity', 'Centroid','Area');

                    ellipsenum = length(rp); %Number of ellipses detected in frame

                    if ellipsenum < 2
                        input = 1;
                    elseif ellipsenum > 1
                        for ii = 1:1:length(rp)
                            [sizesofellipses(ii)] = rp(ii).MajorAxisLength*rp(ii).MinorAxisLength; %Finds the rectangular area of ellipse
                        end
                        [~, input] = max(sizesofellipses);%Determine input that creates largest ellipse based on rectangular area
                        clear 'sizesofellipses'; %Clears array of rectangular areas b/c next iteriation may have less ellipes, so this ensures it doesn't pick a value from a previous iteriation.
                    end

                    %Display plot of largest ellipse (Used code from Steve Eddins' blog article,"Visualizing regionprops ellipse measurements" % _Steve Eddins_% _Copyright 2010 The MathWorks, Inc)

                    phi = linspace(0,2*pi,50);
                    cosphi = cos(phi);
                    sinphi = sin(phi);

                    try
                    for v = input
                        xbar = rp(v).Centroid(1);
                        ybar = rp(v).Centroid(2);

                        a = rp(v).MajorAxisLength/2;
                        b = rp(v).MinorAxisLength/2;

                        theta = pi*rp(v).Orientation/180;
                        R = [cos(theta)   sin(theta)
                            -sin(theta)   cos(theta)];

                        xy = [a*cosphi; b*sinphi];
                        xy = R*xy;

                        x = xy(1,:) + xbar;
                        y = xy(2,:) + ybar;

                        xdistcoord(i,:) = xbar*(real_width_TIFF/pixel_width);
                        ydistcoord(i,:) = ybar*(real_height_TIFF/pixel_height);

                        if i>1
                            app.Speed(i,:) = sqrt((xdistcoord(i,:)-xdistcoord(i-1,:))^2+(ydistcoord(i,:)-ydistcoord(i-1,:))^2)*app.fps;
                        end
                        app.Eccentricity(i,:) = rp(v).Eccentricity;
                        Orientation(i,:) = rp(v).Orientation;
                        MajorAxisLength(i,:) = rp(v).MajorAxisLength;
                        MinorAxisLength(i,:) = rp(v).MinorAxisLength;
                        Area(i,:) = rp(v).Area;
            
                        % Display Ellipsed Rodent

                        imshow(bw_display_image,'Parent',app.Video_Window.EllipseAxes)
                        hold(app.Video_Window.EllipseAxes,"on")
                        if size(rp)>0
                            plot(app.Video_Window.EllipseAxes,x,y,'color',app.EllipseColor,'LineWidth',2);
                        end
                        title(app.Video_Window.EllipseAxes,'Draw Ellipse')
                        scatter(app.Video_Window.EllipseAxes,xbar,ybar,'.','MarkerFaceColor',app.CentroidColor,'MarkerEdgeColor',app.CentroidColor,'SizeData',40)
                        scatter(app.Video_Window.EllipseAxes,x(1),y(1),'.','MarkerFaceColor',app.HeadpointColor,'MarkerEdgeColor',app.HeadpointColor,'SizeData',40)
                        scatter(app.Video_Window.EllipseAxes,x(end/2),y(end/2),'.','MarkerFaceColor',app.TailpointColor,'MarkerEdgeColor',app.TailpointColor,'SizeData',40)
                        hold(app.Video_Window.EllipseAxes,"off")

                        % Display ROIs
        
                        if ~isempty(app.ROI_Data)
                            for ii = 1:size(app.ROI_Data,1)
                                if app.ROI_Data(ii,2)=="1"
                                    Position = str2num(char([app.ROI_Data(ii,6:9)]'))';
                                    if sum(isstrprop(app.ROI_Data(ii,5),'digit'))==0
                                        app.ROI_Raw = drawrectangle(app.Video_Window.RawAxes,'Position',Position,'Color',app.ROI_Data(ii,5));
                                        app.ROI_Binary = drawrectangle(app.Video_Window.BinaryAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                        app.ROI_NoTail = drawrectangle(app.Video_Window.NoTailAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                        app.ROI_Ellipse = drawrectangle(app.Video_Window.EllipseAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                    else
                                        app.ROI_Raw = drawrectangle(app.Video_Window.RawAxes,'Position',Position,'Color',str2num(app.ROI_Data(ii,5)));
                                        app.ROI_Binary = drawrectangle(app.Video_Window.BinaryAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                        app.ROI_NoTail = drawrectangle(app.Video_Window.NoTailAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                        app.ROI_Ellipse = drawrectangle(app.Video_Window.EllipseAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                    end
                                    app.ROI_Raw.InteractionsAllowed='none';
                                    app.ROI_Binary.InteractionsAllowed='none';
                                    app.ROI_NoTail.InteractionsAllowed='none';
                                    app.ROI_Ellipse.InteractionsAllowed='none';
                                    app.ROI.FaceSelectable=0;
                                    app.ROI_Raw.FaceSelectable=0;
                                    app.ROI_Binary.FaceSelectable=0;
                                    app.ROI_NoTail.FaceSelectable=0;
                                    app.ROI_Ellipse.FaceSelectable=0;
                                end
                            end
                        end

                        % Trace
                        if isempty(app.Trace_Window.UIAxes.Children)
                        scatter(app.Trace_Window.UIAxes,xbar,ybar,'.','MarkerFaceColor',app.TraceColor,'MarkerEdgeColor',app.TraceColor)
                        else
                            app.Trace_Window.UIAxes.Children(1).XData = [app.Trace_Window.UIAxes.Children(1).XData xbar];
                            app.Trace_Window.UIAxes.Children(1).YData = [app.Trace_Window.UIAxes.Children(1).YData ybar];
                        end

                        if i >1
                            app.ProgressText.Text = ['Eccentricity:' num2str(rp(v).Eccentricity,'%.2f') ' Speed:' num2str(app.Speed(i,:),'%.2f') ' ' num2str(real_units_TIFF) '/s; x:' num2str(xdistcoord(i,:),'%.2f') ' ' num2str(real_units_TIFF) ' y:' num2str(ydistcoord(i,:),'%.2f') ' ' num2str(real_units_TIFF)];
                        end

                    end
                    catch
                        msgbox('No Rodent was detected')
                    end
                    drawnow
        end
        
        function OpenVideo(app)
                [~,~,ext] = fileparts(fullfile(app.folder,app.filename));
                files = dir(fullfile(app.folder,['*' ext]));
                app.DropDown.Items = {files.name};
                app.DropDown.Value = app.filename;
                pixel_width = app.Image_info.Width;
                pixel_height = app.Image_info.Height;

                app.Trace_Window.UIAxes.XLim = [0 app.Image_info.Width];
                app.Trace_Window.UIAxes.YLim = [0 app.Image_info.Height];

                if isempty(app.real_width)
                    real_dim = inputdlg({'Enter image/frame width:','Enter image/frame name:','Units:'},'Frame Dimensions',[1 45],{'30','30','cm'});
                    app.real_width = str2double(real_dim{1});
                    app.real_height = str2double(real_dim{2});
                    app.real_units = real_dim{3};
                end

                app.fps = app.Image_info.FrameRate;
                app.TimeSlider.Limits(2)=app.Image_info.Duration;

                app.ProgressText.Text = 'Loading...';
                app.ProgressText.Visible = "on";

                app.FileInfoText.Text = {['FPS: ' num2str(app.fps)];['width: ' num2str(app.real_width) ' ' app.real_units];['height: ' num2str(app.real_height) ' ' app.real_units]};
                app.FileInfoText.Visible = "on";
            
            
                i = floor(app.TimeSlider.Value*app.fps+1);

                % preallocate
                app.Speed = zeros(size(app.Image_info,1)-1,1);
                app.Eccentricity = zeros(size(app.Image_info,1)-1,1);
                xdistcoord = zeros(size(app.Image_info,1)-1,1);
                ydistcoord = zeros(size(app.Image_info,1)-1,1);
                Orientation = zeros(size(app.Image_info,1)-1,1);
                MajorAxisLength = zeros(size(app.Image_info,1)-1,1);
                MinorAxisLength = zeros(size(app.Image_info,1)-1,1);
                Area = zeros(size(app.Image_info,1)-1,1);

                if size(size(app.Background_Image),2)==3
                % Convert to Binary Image

                if isfloat(app.Image)

                        if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                            bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < app.BinaryThresholdSlider.Value);
                        else
                            bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) > app.BinaryThresholdSlider.Value;
                        end
                    else
                        if isa(app.Background_Image,'uint8')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < 255*app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < 255*app.BinaryThresholdSlider.Value);
                            else
                                bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) >= 255*app.BinaryThresholdSlider.Value;
                            end

                        end
                        if isa(app.Background_Image,'uint16')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < 65535*app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < 65535*app.BinaryThresholdSlider.Value);
                            else
                                bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) >= 65535*app.BinaryThresholdSlider.Value;
                            end
                        end
                end


                    % Raw Image

                    imshow(app.Image(:,:,:,i),'Parent',app.Video_Window.RawAxes)
                    title(app.Video_Window.RawAxes,'Original Video')
                    
                    % Binary Image

                    imshow(bw_display_image,'Parent',app.Video_Window.BinaryAxes)
                    title(app.Video_Window.BinaryAxes,'Binary Video')
                   
                else
                    % GRAYSCALE TIFF

                    % Convert to Binary Image

                    if isfloat(app.Image)

                        if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                            bw_display_image = (app.Image(:,:,i)<app.BinaryThresholdSlider.Value)-(app.Background_Image<app.BinaryThresholdSlider.Value);
                        else
                            bw_display_image = app.Image(:,:,i)-app.Background_Image > app.BinaryThresholdSlider.Value;
                        end
                    else
                        if isa(app.Background_Image,'uint8')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (app.Image(:,:,i)<= 255*app.BinaryThresholdSlider.Value)-(app.Background_Image<= 255*app.BinaryThresholdSlider.Value);
                            else
                                bw_display_image = app.Image(:,:,i)-app.Background_Image >= 255*app.BinaryThresholdSlider.Value;
                            end

                        end
                        if isa(app.Background_Image,'uint16')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (app.Image(:,:,i)<= 65535*app.BinaryThresholdSlider.Value)-(app.Background_Image<= 65535*app.BinaryThresholdSlider.Value);
                            else
                                bw_display_image = app.Image(:,:,i)-app.Background_Image >= 65535*app.BinaryThresholdSlider.Value;
                            end
                        end
                    end

                    % Raw Image

                    imshow(app.Image(:,:,i),'Parent',app.Video_Window.RawAxes)
                    title(app.Video_Window.RawAxes,'Original Video')

                    % Binary Image

                    imshow(bw_display_image,'Parent',app.Video_Window.BinaryAxes)
                    title(app.Video_Window.BinaryAxes,'Binary Video')

                end

                    % Remove tail
                    se = strel('disk',round(app.StructuralElementSizeSlider.Value));

                    imshow(imopen(bw_display_image,se),'Parent',app.Video_Window.NoTailAxes)
                    title(app.Video_Window.NoTailAxes,'Remove Tail')

                    rp = regionprops(bw_display_image,'Orientation', 'MajorAxisLength', ...
                        'MinorAxisLength', 'Eccentricity', 'Centroid','Area');

                    ellipsenum = length(rp); %Number of ellipses detected in frame

                    if ellipsenum < 2
                        input = 1;
                    elseif ellipsenum > 1
                        for ii = 1:1:length(rp)
                            [sizesofellipses(ii)] = rp(ii).MajorAxisLength*rp(ii).MinorAxisLength; %Finds the rectangular area of ellipse
                        end
                        [~, input] = max(sizesofellipses);%Determine input that creates largest ellipse based on rectangular area
                        clear 'sizesofellipses'; %Clears array of rectangular areas b/c next iteriation may have less ellipes, so this ensures it doesn't pick a value from a previous iteriation.
                    end

                    %Display plot of largest ellipse (Used code from Steve Eddins' blog article,"Visualizing regionprops ellipse measurements" % _Steve Eddins_% _Copyright 2010 The MathWorks, Inc)

                    phi = linspace(0,2*pi,50);
                    cosphi = cos(phi);
                    sinphi = sin(phi);

                    try
                    for v = input
                        xbar = rp(v).Centroid(1);
                        ybar = rp(v).Centroid(2);

                        a = rp(v).MajorAxisLength/2;
                        b = rp(v).MinorAxisLength/2;

                        theta = pi*rp(v).Orientation/180;
                        R = [cos(theta)   sin(theta)
                            -sin(theta)   cos(theta)];

                        xy = [a*cosphi; b*sinphi];
                        xy = R*xy;

                        x = xy(1,:) + xbar;
                        y = xy(2,:) + ybar;

                        xdistcoord(i,:) = xbar*(app.real_width/pixel_width);
                        ydistcoord(i,:) = ybar*(app.real_height/pixel_height);

                        if i>1
                            app.Speed(i,:) = sqrt((xdistcoord(i,:)-xdistcoord(i-1,:))^2+(ydistcoord(i,:)-ydistcoord(i-1,:))^2)*app.fps;
                        end
                        app.Eccentricity(i,:) = rp(v).Eccentricity;
                        Orientation(i,:) = rp(v).Orientation;
                        MajorAxisLength(i,:) = rp(v).MajorAxisLength;
                        MinorAxisLength(i,:) = rp(v).MinorAxisLength;
                        Area(i,:) = rp(v).Area;

                        % Display Ellipsed Rodent
                        imshow(bw_display_image,'Parent',app.Video_Window.EllipseAxes)
                        hold(app.Video_Window.EllipseAxes,"on")
                        if size(rp)>0
                            plot(app.Video_Window.EllipseAxes,x,y,'color',app.EllipseColor,'LineWidth',2);
                        end
                        title(app.Video_Window.EllipseAxes,'Draw Ellipse')
                        scatter(app.Video_Window.EllipseAxes,xbar,ybar,'.','MarkerFaceColor',app.CentroidColor,'MarkerEdgeColor',app.CentroidColor)
                        scatter(app.Video_Window.EllipseAxes,xbar,ybar,'.','MarkerFaceColor',app.CentroidColor,'MarkerEdgeColor',app.CentroidColor,'SizeData',40)
                        scatter(app.Video_Window.EllipseAxes,x(1),y(1),'.','MarkerFaceColor',app.HeadpointColor,'MarkerEdgeColor',app.HeadpointColor,'SizeData',40)
                        scatter(app.Video_Window.EllipseAxes,x(end/2),y(end/2),'.','MarkerFaceColor',app.TailpointColor,'MarkerEdgeColor',app.TailpointColor,'SizeData',40)
                        hold(app.Video_Window.EllipseAxes,"off")

                        % Display ROIs
        
                        if ~isempty(app.ROI_Data)
                            for ii = 1:size(app.ROI_Data,1)
                                if app.ROI_Data(ii,2)=="1"
                                    Position = str2num(char([app.ROI_Data(ii,6:9)]'))';
                                    if sum(isstrprop(app.ROI_Data(ii,5),'digit'))==0
                                        app.ROI_Raw = drawrectangle(app.Video_Window.RawAxes,'Position',Position,'Color',app.ROI_Data(ii,5));
                                        app.ROI_Binary = drawrectangle(app.Video_Window.BinaryAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                        app.ROI_NoTail = drawrectangle(app.Video_Window.NoTailAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                        app.ROI_Ellipse = drawrectangle(app.Video_Window.EllipseAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                    else
                                        app.ROI_Raw = drawrectangle(app.Video_Window.RawAxes,'Position',Position,'Color',str2num(app.ROI_Data(ii,5)));
                                        app.ROI_Binary = drawrectangle(app.Video_Window.BinaryAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                        app.ROI_NoTail = drawrectangle(app.Video_Window.NoTailAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                        app.ROI_Ellipse = drawrectangle(app.Video_Window.EllipseAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                    end
                                    app.ROI_Raw.InteractionsAllowed='none';
                                    app.ROI_Binary.InteractionsAllowed='none';
                                    app.ROI_NoTail.InteractionsAllowed='none';
                                    app.ROI_Ellipse.InteractionsAllowed='none';
                                    app.ROI.FaceSelectable=0;
                                    app.ROI_Raw.FaceSelectable=0;
                                    app.ROI_Binary.FaceSelectable=0;
                                    app.ROI_NoTail.FaceSelectable=0;
                                    app.ROI_Ellipse.FaceSelectable=0;
                                end
                            end
                        end

                        % Trace
                        if isempty(app.Trace_Window.UIAxes.Children)
                        scatter(app.Trace_Window.UIAxes,xbar,ybar,'.','MarkerFaceColor',app.TraceColor,'MarkerEdgeColor',app.TraceColor)
                        else
                            app.Trace_Window.UIAxes.Children(1).XData = [app.Trace_Window.UIAxes.Children(1).XData xbar];
                            app.Trace_Window.UIAxes.Children(1).YData = [app.Trace_Window.UIAxes.Children(1).YData ybar];
                        end

                        if i >1
                            app.ProgressText.Text = ['Eccentricity:' num2str(rp(v).Eccentricity,'%.2f') ' Speed:' num2str(app.Speed(i,:),'%.2f') ' ' num2str(app.real_units) '/s; x:' num2str(xdistcoord(i,:),'%.2f') ' ' num2str(app.real_units) ' y:' num2str(ydistcoord(i,:),'%.2f') ' ' num2str(app.real_units)];
                        end

                    end
                    catch
                    end
                    drawnow
        end
    end
    

    % Callbacks that handle component events
    methods

        % Code that executes after component creation
        function startupFcn(app)
            %Position
            screen = get(0,'screensize');
            xres = screen(3)-screen(1);
            yres = screen(4)-screen(2);

            app.RodentTrackerUIFigure.Units = 'normalized';
            app.RodentTrackerUIFigure.Position(1) = 0.06;
            app.RodentTrackerUIFigure.Position(2) = 0.55;
            app.RodentTrackerUIFigure.Position(3) = 3*0.47*(yres/xres)+2*(((0.9426-0.47*(yres/xres)-(0.06+0.47*(yres/xres)))-0.47*(yres/xres))/2);
            
            appFolder = fileparts(mfilename('fullpath'));
            addpath(appFolder, fullfile(fileparts(appFolder), 'Rodent Tracker_resources'))
            
            app.SAP_Window = RodentTracker_SAP_Window(app);
        end

        % Button pushed function: LoadVideoButton
        function LoadVideoButtonPushed(app, event)
            [app.filename, app.folder] = uigetfile('*.*');


            if app.start == 1
                app.Trace_Window = RodentTracker_Trace_Window(app);
                app.Video_Window = RodentTracker_Video_Window(app);
                app.Spreadsheet_Window = RodentTracker_Spreadsheet_Window(app);
                app.ROI_Results_Window = RodentTracker_ROI_Results_Window(app);
                app.start = 0;
            end

            app.Video_Window.RodentTrackerAnalysisPreviewUIFigure.Visible ="on";
            app.Trace_Window.RodentTrackerTraceUIFigure.Visible ="on";
%             app.Spreadsheet_Window.RodentTrackerSpreadsheetUIFigure.Visible ="on";
            figure(app.Video_Window.RodentTrackerAnalysisPreviewUIFigure)
            figure(app.Trace_Window.RodentTrackerTraceUIFigure)
%             figure(app.Spreadsheet_Window.RodentTrackerSpreadsheetUIFigure)

            figure(app.RodentTrackerUIFigure)
            [app.Image, app.Background_Image, app.Image_info] = Extract_video_matrix(fullfile(app.folder,app.filename));

            app.Trace_Window.UIAxes.Units = "Normalized";
            app.Trace_Window.UIAxes.Position = [0 0 1 1];

            imshow(zeros(size(app.Background_Image)),"Parent",app.Video_Window.RawAxes)
            imshow(zeros(size(app.Background_Image)),"Parent",app.Video_Window.BinaryAxes)
            imshow(zeros(size(app.Background_Image)),"Parent",app.Video_Window.NoTailAxes)
            imshow(zeros(size(app.Background_Image)),"Parent",app.Video_Window.EllipseAxes)
%             imshow(zeros(size(app.Background_Image)),"Parent",app.Trace_Window.UIAxes)
            
            xlim(app.Video_Window.RawAxes,[0 size(app.Background_Image,1)]);
            ylim(app.Video_Window.RawAxes,[0 size(app.Background_Image,2)]);
            xlim(app.Video_Window.BinaryAxes,[0 size(app.Background_Image,1)]);
            ylim(app.Video_Window.BinaryAxes,[0 size(app.Background_Image,2)]);
            xlim(app.Video_Window.NoTailAxes,[0 size(app.Background_Image,1)]);
            ylim(app.Video_Window.NoTailAxes,[0 size(app.Background_Image,2)]);
            xlim(app.Video_Window.EllipseAxes,[0 size(app.Background_Image,1)]);
            ylim(app.Video_Window.EllipseAxes,[0 size(app.Background_Image,2)]);

            if size(app.Image_info,1)>1
                OpenTiffImage(app)
            else
                OpenVideo(app)
            end

            app.EditMenu.Enable = "on";
            app.ViewMenu.Enable = "on";
            app.DropDown.Enable = "on";
            app.TimeSlider.Enable = "on";
            app.BinaryThresholdSlider.Enable = "on";
            app.StructuralElementSizeSlider.Enable = "on";
            app.TimeSliderLabel.Enable = "on";
            app.BinaryThresholdLabel.Enable = "on";
            app.StructuralElementSizeLabel.Enable = "on";
            app.AnalyzeButton.Enable ="on";
            app.PlayButton.Enable = "on";
            app.SEThresholdEditField.Enable = "on";
            app.TimesEditField.Enable = "on";
            app.BinaryThresholdEditField.Enable = "on";
            app.ClearTraceButton.Enable = "on";
            app.RightArrowSEThresholdSlider.Enable = "on";
            app.RightArrowBinaryThresholdSlider.Enable = "on";
            app.RightArrowTimeSlider.Enable = "on";
            app.LeftArrowSEThresholdSlider.Enable = "on";
            app.LeftArrowBinaryThresholdSlider.Enable = "on";
            app.LeftArrowTimeSlider.Enable = "on";
            app.FileInfoText.Enable = "on";
            app.AnalyzeMenu.Enable = "on";
            app.BackgroundButtonGroup.Enable = "on";
            app.LightButton.Enable = "on";
            app.DarkButton.Enable = "on";
            app.ProgressText.Text = 'Done';

            figure(app.Video_Window.RodentTrackerAnalysisPreviewUIFigure)
            figure(app.Trace_Window.RodentTrackerTraceUIFigure)
%             figure(app.Spreadsheet_Window.RodentTrackerSpreadsheetUIFigure)
            figure(app.RodentTrackerUIFigure)
            
        end

        % Value changed function: TimeSlider
        function TimeSliderValueChanged(app, event)
            app.TimesEditField.Value = app.TimeSlider.Value;
            if size(app.Image_info,1)>1
                OpenTiffImage(app)
            else
                OpenVideo(app)
            end
        end

        % Value changing function: TimeSlider
        function TimeSliderValueChanging(app, event)
            changingValue = event.Value;
           if size(app.Image_info,1)>1
            % If TIFF
                files = dir(fullfile(app.folder,'*.tif'));
                app.DropDown.Items = {files.name};
                app.DropDown.Value = app.filename;
                pixel_width = app.Image_info(1).Width;
                pixel_height = app.Image_info(1).Height;

                app.Trace_Window.RodentTrackerTraceUIFigure.Visible ="on";
 
                app.Trace_Window.UIAxes.XLim = [0 app.Image_info(1).Width];
                app.Trace_Window.UIAxes.YLim = [0 app.Image_info(1).Height];

                if isempty(app.Image_info(1).XResolution)
                    real_dim = inputdlg({'Enter image/frame width:','Enter image/frame name:','Units:'},'Frame Dimensions',[1 45],{'30','30','cm'});
                    real_width_TIFF = str2double(real_dim{1});
                    real_height_TIFF = str2double(real_dim{2});
                    real_units_TIFF = real_dim{3};
                    app.Image_info(1).XResolution = real_width_TIFF;
                    app.Image_info(1).YResolution = real_height_TIFF;
                    app.Image_info(1).ResolutionUnit = real_units_TIFF;
                else
                    real_width_TIFF = app.Image_info(1).XResolution;
                    real_height_TIFF = app.Image_info(1).YResolution;
                    real_units_TIFF = app.Image_info(1).ResolutionUnit;
                end

                app.ProgressText.Text = 'Loading...';
                app.ProgressText.Visible = "on";

                app.FileInfoText.Text = {['FPS: ' num2str(app.fps)];['width: ' num2str(real_width_TIFF) ' ' real_units_TIFF];['height: ' num2str(real_height_TIFF) ' ' real_units_TIFF]};
                app.FileInfoText.Visible = "on";

                i = floor(changingValue*app.fps+1);

                % preallocate
                app.Speed = zeros(size(app.Image_info,1)-1,1);
                app.Eccentricity = zeros(size(app.Image_info,1)-1,1);
                xdistcoord = zeros(size(app.Image_info,1)-1,1);
                ydistcoord = zeros(size(app.Image_info,1)-1,1);
                Orientation = zeros(size(app.Image_info,1)-1,1);
                MajorAxisLength = zeros(size(app.Image_info,1)-1,1);
                MinorAxisLength = zeros(size(app.Image_info,1)-1,1);
                Area = zeros(size(app.Image_info,1)-1,1);

                if size(size(app.Background_Image),2) == 3
                    % Convert to Binary Image

                     if isfloat(app.Image)

                        if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                            bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < app.BinaryThresholdSlider.Value);
                        else
                            bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) > app.BinaryThresholdSlider.Value;
                        end
                    else
                        if isa(app.Background_Image,'uint8')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < 255*app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < 255*app.BinaryThresholdSlider.Value);
                            else
                                bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) >= 255*app.BinaryThresholdSlider.Value;
                            end

                        end
                        if isa(app.Background_Image,'uint16')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < 65535*app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < 65535*app.BinaryThresholdSlider.Value);
                            else
                                bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) >= 65535*app.BinaryThresholdSlider.Value;
                            end
                        end
                     end

                    % Display Images

                    % Raw Image

                    app.Video_Window.RodentTrackerAnalysisPreviewUIFigure.Visible ="on";

                    imshow(app.Image(:,:,:,i),'Parent',app.Video_Window.RawAxes)
                    title(app.Video_Window.RawAxes,'Original Video')
                    % Binary Image

                    imshow(bw_display_image,'Parent',app.Video_Window.BinaryAxes)
                    title(app.Video_Window.BinaryAxes,'Binary Video')
                   
                else
                    % GRAYSCALE TIFF

                    % Convert to Binary Image

                             if isfloat(app.Image)

                        if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                            bw_display_image = (app.Image(:,:,i)<app.BinaryThresholdSlider.Value)-(app.Background_Image<app.BinaryThresholdSlider.Value);
                        else
                            bw_display_image = app.Image(:,:,i)-app.Background_Image > app.BinaryThresholdSlider.Value;
                        end
                    else
                        if isa(app.Background_Image,'uint8')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (app.Image(:,:,i)<= 255*app.BinaryThresholdSlider.Value)-(app.Background_Image<= 255*app.BinaryThresholdSlider.Value);
                            else
                                bw_display_image = app.Image(:,:,i)-app.Background_Image >= 255*app.BinaryThresholdSlider.Value;
                            end

                        end
                        if isa(app.Background_Image,'uint16')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (app.Image(:,:,i)<= 65535*app.BinaryThresholdSlider.Value)-(app.Background_Image<= 65535*app.BinaryThresholdSlider.Value);
                            else
                                bw_display_image = app.Image(:,:,i)-app.Background_Image >= 65535*app.BinaryThresholdSlider.Value;
                            end
                        end
                             end

                    % Raw Image

                    app.Video_Window.RodentTrackerAnalysisPreviewUIFigure.Visible ="on";

                    imshow(app.Image(:,:,i),'Parent',app.Video_Window.RawAxes)
                    title(app.Video_Window.RawAxes,'Original Video')
                    % Binary Image

                    imshow(bw_display_image,'Parent',app.Video_Window.BinaryAxes)
                    title(app.Video_Window.BinaryAxes,'Binary Video')
                   
                end

                 % Remove tail
                    se = strel('disk',round(app.StructuralElementSizeSlider.Value));

                    imshow(imopen(bw_display_image,se),'Parent',app.Video_Window.NoTailAxes)
                    title(app.Video_Window.NoTailAxes,'Remove Tail')

                    rp = regionprops(bw_display_image,'Orientation', 'MajorAxisLength', ...
                        'MinorAxisLength', 'Eccentricity', 'Centroid','Area');

                    ellipsenum = length(rp); %Number of ellipses detected in frame

                    if ellipsenum < 2
                        input = 1;
                    elseif ellipsenum > 1
                        for ii = 1:1:length(rp)
                            [sizesofellipses(ii)] = rp(ii).MajorAxisLength*rp(ii).MinorAxisLength; %Finds the rectangular area of ellipse
                        end
                        [~, input] = max(sizesofellipses);%Determine input that creates largest ellipse based on rectangular area
                        clear 'sizesofellipses'; %Clears array of rectangular areas b/c next iteriation may have less ellipes, so this ensures it doesn't pick a value from a previous iteriation.
                    end

                    %Display plot of largest ellipse (Used code from Steve Eddins' blog article,"Visualizing regionprops ellipse measurements" % _Steve Eddins_% _Copyright 2010 The MathWorks, Inc)

                    phi = linspace(0,2*pi,50);
                    cosphi = cos(phi);
                    sinphi = sin(phi);

                    try
                    for v = input
                        xbar = rp(v).Centroid(1);
                        ybar = rp(v).Centroid(2);

                        a = rp(v).MajorAxisLength/2;
                        b = rp(v).MinorAxisLength/2;

                        theta = pi*rp(v).Orientation/180;
                        R = [cos(theta)   sin(theta)
                            -sin(theta)   cos(theta)];

                        xy = [a*cosphi; b*sinphi];
                        xy = R*xy;

                        x = xy(1,:) + xbar;
                        y = xy(2,:) + ybar;

                        xdistcoord(i,:) = xbar*(real_width_TIFF/pixel_width);
                        ydistcoord(i,:) = ybar*(real_height_TIFF/pixel_height);

                        if i>1
                            app.Speed(i,:) = sqrt((xdistcoord(i,:)-xdistcoord(i-1,:))^2+(ydistcoord(i,:)-ydistcoord(i-1,:))^2)*app.fps;
                        end
                        app.Eccentricity(i,:) = rp(v).Eccentricity;
                        Orientation(i,:) = rp(v).Orientation;
                        MajorAxisLength(i,:) = rp(v).MajorAxisLength;
                        MinorAxisLength(i,:) = rp(v).MinorAxisLength;
                        Area(i,:) = rp(v).Area;
            
                        % Display Ellipsed Rodent
                        imshow(bw_display_image,'Parent',app.Video_Window.EllipseAxes)
                        hold(app.Video_Window.EllipseAxes,"on")
                        if size(rp)>0
                            plot(app.Video_Window.EllipseAxes,x,y,'color',app.EllipseColor,'LineWidth',2);
                        end
                        title(app.Video_Window.EllipseAxes,'Draw Ellipse')
                        scatter(app.Video_Window.EllipseAxes,xbar,ybar,'.','MarkerFaceColor',app.CentroidColor,'MarkerEdgeColor',app.CentroidColor,'SizeData',40)
                        scatter(app.Video_Window.EllipseAxes,x(1),y(1),'.','MarkerFaceColor',app.HeadpointColor,'MarkerEdgeColor',app.HeadpointColor,'SizeData',40)
                        scatter(app.Video_Window.EllipseAxes,x(end/2),y(end/2),'.','MarkerFaceColor',app.TailpointColor,'MarkerEdgeColor',app.TailpointColor,'SizeData',40)
                        
                        hold(app.Video_Window.EllipseAxes,"off")

                       % Display ROIs
        
                        if ~isempty(app.ROI_Data)
                            for ii = 1:size(app.ROI_Data,1)
                                if app.ROI_Data(ii,2)=="1"
                                    Position = str2num(char([app.ROI_Data(ii,6:9)]'))';
                                    if sum(isstrprop(app.ROI_Data(ii,5),'digit'))==0
                                        app.ROI_Raw = drawrectangle(app.Video_Window.RawAxes,'Position',Position,'Color',app.ROI_Data(ii,5));
                                        app.ROI_Binary = drawrectangle(app.Video_Window.BinaryAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                        app.ROI_NoTail = drawrectangle(app.Video_Window.NoTailAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                        app.ROI_Ellipse = drawrectangle(app.Video_Window.EllipseAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                    else
                                        app.ROI_Raw = drawrectangle(app.Video_Window.RawAxes,'Position',Position,'Color',str2num(app.ROI_Data(ii,5)));
                                        app.ROI_Binary = drawrectangle(app.Video_Window.BinaryAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                        app.ROI_NoTail = drawrectangle(app.Video_Window.NoTailAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                        app.ROI_Ellipse = drawrectangle(app.Video_Window.EllipseAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                    end
                                    app.ROI_Raw.InteractionsAllowed='none';
                                    app.ROI_Binary.InteractionsAllowed='none';
                                    app.ROI_NoTail.InteractionsAllowed='none';
                                    app.ROI_Ellipse.InteractionsAllowed='none';
                                    app.ROI.FaceSelectable=0;
                                    app.ROI_Raw.FaceSelectable=0;
                                    app.ROI_Binary.FaceSelectable=0;
                                    app.ROI_NoTail.FaceSelectable=0;
                                    app.ROI_Ellipse.FaceSelectable=0;
                                end
                            end
                        end


                        % Trace
                        if isempty(app.Trace_Window.UIAxes.Children)
                        scatter(app.Trace_Window.UIAxes,xbar,ybar,'.','MarkerFaceColor',app.TraceColor,'MarkerEdgeColor',app.TraceColor)
                        else
                            app.Trace_Window.UIAxes.Children(1).XData = [app.Trace_Window.UIAxes.Children(1).XData xbar];
                            app.Trace_Window.UIAxes.Children(1).YData = [app.Trace_Window.UIAxes.Children(1).YData ybar];
                        end

                        if i >1
                            app.ProgressText.Text = ['Eccentricity:' num2str(rp(v).Eccentricity,'%.2f') ' Speed:' num2str(app.Speed(i,:),'%.2f') ' ' num2str(real_units_TIFF) '/s; x:' num2str(xdistcoord(i,:),'%.2f') ' ' num2str(real_units_TIFF) ' y:' num2str(ydistcoord(i,:),'%.2f') ' ' num2str(real_units_TIFF)];
                        end

                    end
                    catch
                        msgbox('No Rodent was detected')
                    end
                    drawnow
         
        
        else
                [~,~,ext] = fileparts(fullfile(app.folder,app.filename));
                files = dir(fullfile(app.folder,['*' ext]));
                app.DropDown.Items = {files.name};
                app.DropDown.Value = app.filename;
                pixel_width = app.Image_info.Width;
                pixel_height = app.Image_info.Height;

                app.Trace_Window.RodentTrackerTraceUIFigure.Visible ="on";

                app.Trace_Window.UIAxes.XLim = [0 app.Image_info.Width];
                app.Trace_Window.UIAxes.YLim = [0 app.Image_info.Height];

                if isempty(app.real_width)
                    real_dim = inputdlg({'Enter image/frame width:','Enter image/frame name:','Units:'},'Frame Dimensions',[1 45],{'30','30','cm'});
                    app.real_width = str2double(real_dim{1});
                    app.real_height = str2double(real_dim{2});
                    app.real_units = real_dim{3};
                end

                app.fps = app.Image_info.FrameRate;
                app.TimeSlider.Limits(2)=app.Image_info.Duration;

                app.ProgressText.Text = 'Loading...';
                app.ProgressText.Visible = "on";

                app.FileInfoText.Text = {['FPS: ' num2str(app.fps)];['width: ' num2str(app.real_width) ' ' app.real_units];['height: ' num2str(app.real_height) ' ' app.real_units]};
                app.FileInfoText.Visible = "on";
            
            
                i = floor(changingValue*app.fps+1);

                % preallocate
                app.Speed = zeros(size(app.Image_info,1)-1,1);
                app.Eccentricity = zeros(size(app.Image_info,1)-1,1);
                xdistcoord = zeros(size(app.Image_info,1)-1,1);
                ydistcoord = zeros(size(app.Image_info,1)-1,1);
                Orientation = zeros(size(app.Image_info,1)-1,1);
                MajorAxisLength = zeros(size(app.Image_info,1)-1,1);
                MinorAxisLength = zeros(size(app.Image_info,1)-1,1);
                Area = zeros(size(app.Image_info,1)-1,1);

                if size(size(app.Background_Image),2)==3
                % Convert to Binary Image

                if isfloat(app.Image)

                        if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                            bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < app.BinaryThresholdSlider.Value);
                        else
                            bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) > app.BinaryThresholdSlider.Value;
                        end
                    else
                        if isa(app.Background_Image,'uint8')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < 255*app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < 255*app.BinaryThresholdSlider.Value);
                            else
                                bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) >= 255*app.BinaryThresholdSlider.Value;
                            end

                        end
                        if isa(app.Background_Image,'uint16')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < 65535*app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < 65535*app.BinaryThresholdSlider.Value);
                            else
                                bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) >= 65535*app.BinaryThresholdSlider.Value;
                            end
                        end
                end


                    % Raw Image

                    app.Video_Window.RodentTrackerAnalysisPreviewUIFigure.Visible ="on";

                    imshow(app.Image(:,:,:,i),'Parent',app.Video_Window.RawAxes)
                    title(app.Video_Window.RawAxes,'Original Video')
                    
                    % Binary Image

                    imshow(bw_display_image,'Parent',app.Video_Window.BinaryAxes)
                    title(app.Video_Window.BinaryAxes,'Binary Video')
                   
                else
                    % GRAYSCALE TIFF

                    % Convert to Binary Image

                    if isfloat(app.Image)

                        if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                            bw_display_image = (app.Image(:,:,i)<app.BinaryThresholdSlider.Value)-(app.Background_Image<app.BinaryThresholdSlider.Value);
                        else
                            bw_display_image = app.Image(:,:,i)-app.Background_Image > app.BinaryThresholdSlider.Value;
                        end
                    else
                        if isa(app.Background_Image,'uint8')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (app.Image(:,:,i)<= 255*app.BinaryThresholdSlider.Value)-(app.Background_Image<= 255*app.BinaryThresholdSlider.Value);
                            else
                                bw_display_image = app.Image(:,:,i)-app.Background_Image >= 255*app.BinaryThresholdSlider.Value;
                            end

                        end
                        if isa(app.Background_Image,'uint16')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (app.Image(:,:,i)<= 65535*app.BinaryThresholdSlider.Value)-(app.Background_Image<= 65535*app.BinaryThresholdSlider.Value);
                            else
                                bw_display_image = app.Image(:,:,i)-app.Background_Image >= 65535*app.BinaryThresholdSlider.Value;
                            end
                        end
                    end

                    % Raw Image

                    app.Video_Window.RodentTrackerAnalysisPreviewUIFigure.Visible ="on";

                    imshow(app.Image(:,:,i),'Parent',app.Video_Window.RawAxes)
                    title(app.Video_Window.RawAxes,'Original Video')

                    % Binary Image

                    imshow(bw_display_image,'Parent',app.Video_Window.BinaryAxes)
                    title(app.Video_Window.BinaryAxes,'Binary Video')

                end

                    % Remove tail
                    se = strel('disk',round(app.StructuralElementSizeSlider.Value));

                    imshow(imopen(bw_display_image,se),'Parent',app.Video_Window.NoTailAxes)
                    title(app.Video_Window.NoTailAxes,'Remove Tail')

                    rp = regionprops(bw_display_image,'Orientation', 'MajorAxisLength', ...
                        'MinorAxisLength', 'Eccentricity', 'Centroid','Area');

                    ellipsenum = length(rp); %Number of ellipses detected in frame

                    if ellipsenum < 2
                        input = 1;
                    elseif ellipsenum > 1
                        for ii = 1:1:length(rp)
                            [sizesofellipses(ii)] = rp(ii).MajorAxisLength*rp(ii).MinorAxisLength; %Finds the rectangular area of ellipse
                        end
                        [~, input] = max(sizesofellipses);%Determine input that creates largest ellipse based on rectangular area
                        clear 'sizesofellipses'; %Clears array of rectangular areas b/c next iteriation may have less ellipes, so this ensures it doesn't pick a value from a previous iteriation.
                    end

                    %Display plot of largest ellipse (Used code from Steve Eddins' blog article,"Visualizing regionprops ellipse measurements" % _Steve Eddins_% _Copyright 2010 The MathWorks, Inc)

                    phi = linspace(0,2*pi,50);
                    cosphi = cos(phi);
                    sinphi = sin(phi);

                    try
                    for v = input
                        xbar = rp(v).Centroid(1);
                        ybar = rp(v).Centroid(2);

                        a = rp(v).MajorAxisLength/2;
                        b = rp(v).MinorAxisLength/2;

                        theta = pi*rp(v).Orientation/180;
                        R = [cos(theta)   sin(theta)
                            -sin(theta)   cos(theta)];

                        xy = [a*cosphi; b*sinphi];
                        xy = R*xy;

                        x = xy(1,:) + xbar;
                        y = xy(2,:) + ybar;

                        xdistcoord(i,:) = xbar*(app.real_width/pixel_width);
                        ydistcoord(i,:) = ybar*(app.real_height/pixel_height);

                        if i>1
                            app.Speed(i,:) = sqrt((xdistcoord(i,:)-xdistcoord(i-1,:))^2+(ydistcoord(i,:)-ydistcoord(i-1,:))^2)*app.fps;
                        end
                        app.Eccentricity(i,:) = rp(v).Eccentricity;
                        Orientation(i,:) = rp(v).Orientation;
                        MajorAxisLength(i,:) = rp(v).MajorAxisLength;
                        MinorAxisLength(i,:) = rp(v).MinorAxisLength;
                        Area(i,:) = rp(v).Area;

                        % Display Ellipsed Rodent
                        imshow(bw_display_image,'Parent',app.Video_Window.EllipseAxes)
                        hold(app.Video_Window.EllipseAxes,"on")
                        if size(rp)>0
                            plot(app.Video_Window.EllipseAxes,x,y,'color',app.EllipseColor,'LineWidth',2);
                        end
                        title(app.Video_Window.EllipseAxes,'Draw Ellipse')
                        scatter(app.Video_Window.EllipseAxes,xbar,ybar,'.','MarkerFaceColor',app.CentroidColor,'MarkerEdgeColor',app.CentroidColor)
                        hold(app.Video_Window.EllipseAxes,"off")

                        % Display ROIs

                        if ~isempty(app.ROI_Data)
                            for ii = 1:size(app.ROI_Data,1)
                                if app.ROI_Data(ii,2)=="1"
                                    Position = str2num(char([app.ROI_Data(ii,6:9)]'))';
                                    if sum(isstrprop(app.ROI_Data(ii,5),'digit'))==0
                                        app.ROI_Raw = drawrectangle(app.Video_Window.RawAxes,'Position',Position,'Color',app.ROI_Data(ii,5));
                                        app.ROI_Binary = drawrectangle(app.Video_Window.BinaryAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                        app.ROI_NoTail = drawrectangle(app.Video_Window.NoTailAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                        app.ROI_Ellipse = drawrectangle(app.Video_Window.EllipseAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                    else
                                        app.ROI_Raw = drawrectangle(app.Video_Window.RawAxes,'Position',Position,'Color',str2num(app.ROI_Data(ii,5)));
                                        app.ROI_Binary = drawrectangle(app.Video_Window.BinaryAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                        app.ROI_NoTail = drawrectangle(app.Video_Window.NoTailAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                        app.ROI_Ellipse = drawrectangle(app.Video_Window.EllipseAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                    end
                                    app.ROI_Raw.InteractionsAllowed='none';
                                    app.ROI_Binary.InteractionsAllowed='none';
                                    app.ROI_NoTail.InteractionsAllowed='none';
                                    app.ROI_Ellipse.InteractionsAllowed='none';
                                    app.ROI.FaceSelectable=0;
                                    app.ROI_Raw.FaceSelectable=0;
                                    app.ROI_Binary.FaceSelectable=0;
                                    app.ROI_NoTail.FaceSelectable=0;
                                    app.ROI_Ellipse.FaceSelectable=0;
                                end
                            end
                        end


                        % Trace

                        if isempty(app.Trace_Window.UIAxes.Children)
                            scatter(app.Trace_Window.UIAxes,xbar,ybar,'.','MarkerFaceColor',app.TraceColor,'MarkerEdgeColor',app.TraceColor)
                        else
                            app.Trace_Window.UIAxes.Children(1).XData = [app.Trace_Window.UIAxes.Children(1).XData xbar];
                            app.Trace_Window.UIAxes.Children(1).YData = [app.Trace_Window.UIAxes.Children(1).YData ybar];
                        end

                        if i >1
                            app.ProgressText.Text = ['Eccentricity:' num2str(rp(v).Eccentricity,'%.2f') ' Speed:' num2str(app.Speed(i,:),'%.2f') ' ' num2str(app.real_units) '/s; x:' num2str(xdistcoord(i,:),'%.2f') ' ' num2str(app.real_units) ' y:' num2str(ydistcoord(i,:),'%.2f') ' ' num2str(app.real_units)];
                        end

                    end
                    catch
                    end
                    drawnow
           end

        end

        % Value changed function: BinaryThresholdSlider
        function BinaryThresholdSliderValueChanged(app, event)
            app.BinaryThresholdEditField.Value = app.BinaryThresholdSlider.Value;
            if size(app.Image_info,1)>1
                OpenTiffImage(app)
            else
                OpenVideo(app)
            end
        end

        % Value changing function: BinaryThresholdSlider
        function BinaryThresholdSliderValueChanging(app, event)
            changingValue = event.Value;
            if size(app.Image_info,1)>1

                % If TIFF

                pixel_width = app.Image_info(1).Width;
                pixel_height = app.Image_info(1).Height;

                if isempty(app.Image_info(1).XResolution)
                    real_dim = inputdlg({'Enter image/frame width:','Enter image/frame name:','Units:'},'Frame Dimensions',[1 45],{'30','30','cm'});
                    real_width_TIFF = str2double(real_dim{1});
                    real_height_TIFF = str2double(real_dim{2});
                    real_units_TIFF = real_dim{3};
                else
                    real_width_TIFF = app.Image_info(1).XResolution;
                    real_height_TIFF = app.Image_info(1).YResolution;
                    real_units_TIFF = app.Image_info(1).ResolutionUnit;
                end

                app.ProgressText.Text = 'Updating...';
                app.ProgressText.Visible = "on";

                i = floor(app.TimeSlider.Value*app.fps+1);

                % preallocate
                app.Speed = zeros(size(app.Image_info,1)-1,1);
                app.Eccentricity = zeros(size(app.Image_info,1)-1,1);
                xdistcoord = zeros(size(app.Image_info,1)-1,1);
                ydistcoord = zeros(size(app.Image_info,1)-1,1);
                Orientation = zeros(size(app.Image_info,1)-1,1);
                MajorAxisLength = zeros(size(app.Image_info,1)-1,1);
                MinorAxisLength = zeros(size(app.Image_info,1)-1,1);
                Area = zeros(size(app.Image_info,1)-1,1);

                if size(size(app.Background_Image),2) == 3
                    % Convert to Binary Image

                    if isfloat(app.Image)

                        if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                            bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < changingValue)-(rgb2gray(app.Background_Image) < changingValue);
                        else
                            bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) > changingValue;
                        end
                    else
                        if isa(app.Background_Image,'uint8')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < 255*changingValue)-(rgb2gray(app.Background_Image) < 255*changingValue);
                            else
                                bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) >= 255*changingValue;
                            end

                        end
                        if isa(app.Background_Image,'uint16')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < 65535*changingValue)-(rgb2gray(app.Background_Image) < 65535*changingValue);
                            else
                                bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) >= 65535*changingValue;
                            end
                        end
                    end

                    % Display Images

                    % Raw Image

                    imshow(app.Image(:,:,:,i),'Parent',app.Video_Window.RawAxes)
                    title(app.Video_Window.RawAxes,'Original Video')
                    % Binary Image

                    imshow(bw_display_image,'Parent',app.Video_Window.BinaryAxes)
                    title(app.Video_Window.BinaryAxes,'Binary Video')
                    % Remove tail
                    se = strel('disk',app.StructuralElementSizeSlider.Value);

                    bw_display_image_NT = imopen(bw_display_image,se);

                    imshow(bw_display_image_NT,'Parent',app.Video_Window.NoTailAxes)
                    title(app.Video_Window.NoTailAxes,'Remove Tail')

                    rp = regionprops(bw_display_image_NT,'Orientation', 'MajorAxisLength', ...
                        'MinorAxisLength', 'Eccentricity', 'Centroid','Area');

                    ellipsenum = length(rp); %Number of ellipses detected in frame

                    if ellipsenum < 2
                        input = 1;
                    elseif ellipsenum > 1
                        for ii = 1:1:length(rp)
                            [sizesofellipses(ii)] = rp(ii).MajorAxisLength*rp(ii).MinorAxisLength; %Finds the rectangular area of ellipse
                        end
                        [~, input] = max(sizesofellipses);%Determine input that creates largest ellipse based on rectangular area
                        clear 'sizesofellipses'; %Clears array of rectangular areas b/c next iteriation may have less ellipes, so this ensures it doesn't pick a value from a previous iteriation.
                    end

                    %Display plot of largest ellipse (Used code from Steve Eddins' blog article,"Visualizing regionprops ellipse measurements" % _Steve Eddins_% _Copyright 2010 The MathWorks, Inc)

                    phi = linspace(0,2*pi,50);
                    cosphi = cos(phi);
                    sinphi = sin(phi);

                    try
                    for v = input
                        xbar = rp(v).Centroid(1);
                        ybar = rp(v).Centroid(2);

                        a = rp(v).MajorAxisLength/2;
                        b = rp(v).MinorAxisLength/2;

                        theta = pi*rp(v).Orientation/180;
                        R = [cos(theta)   sin(theta)
                            -sin(theta)   cos(theta)];

                        xy = [a*cosphi; b*sinphi];
                        xy = R*xy;

                        x = xy(1,:) + xbar;
                        y = xy(2,:) + ybar;

                        xdistcoord(i,:) = xbar*(real_width_TIFF/pixel_width);
                        ydistcoord(i,:) = ybar*(real_height_TIFF/pixel_height);

                        if i>1
                            app.Speed(i,:) = sqrt((xdistcoord(i,:)-xdistcoord(i-1,:))^2+(ydistcoord(i,:)-ydistcoord(i-1,:))^2)*app.fps;
                        end
                        app.Eccentricity(i,:) = rp(v).Eccentricity;
                        Orientation(i,:) = rp(v).Orientation;
                        MajorAxisLength(i,:) = rp(v).MajorAxisLength;
                        MinorAxisLength(i,:) = rp(v).MinorAxisLength;
                        Area(i,:) = rp(v).Area;

                        % Display Ellipsed Rodent
                        imshow(bw_display_image,'Parent',app.Video_Window.EllipseAxes)
                        hold(app.Video_Window.EllipseAxes,"on")
                        if size(rp)>0
                            plot(app.Video_Window.EllipseAxes,x,y,'color',app.EllipseColor,'LineWidth',2);
                        end
                        title(app.Video_Window.EllipseAxes,'Draw Ellipse')
                        scatter(app.Video_Window.EllipseAxes,xbar,ybar,'.','MarkerFaceColor',app.CentroidColor,'MarkerEdgeColor',app.CentroidColor)
                        hold(app.Video_Window.EllipseAxes,"off")

                        % Display ROIs

                        if ~isempty(app.ROI_Data)
                            for ii = 1:size(app.ROI_Data,1)
                                if app.ROI_Data(ii,2)=="1"
                                    Position = str2num(char([app.ROI_Data(ii,6:9)]'))';
                                    if sum(isstrprop(app.ROI_Data(ii,5),'digit'))==0
                                        app.ROI_Raw = drawrectangle(app.Video_Window.RawAxes,'Position',Position,'Color',app.ROI_Data(ii,5));
                                        app.ROI_Binary = drawrectangle(app.Video_Window.BinaryAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                        app.ROI_NoTail = drawrectangle(app.Video_Window.NoTailAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                        app.ROI_Ellipse = drawrectangle(app.Video_Window.EllipseAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                    else
                                        app.ROI_Raw = drawrectangle(app.Video_Window.RawAxes,'Position',Position,'Color',str2num(app.ROI_Data(ii,5)));
                                        app.ROI_Binary = drawrectangle(app.Video_Window.BinaryAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                        app.ROI_NoTail = drawrectangle(app.Video_Window.NoTailAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                        app.ROI_Ellipse = drawrectangle(app.Video_Window.EllipseAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                    end
                                    app.ROI_Raw.InteractionsAllowed='none';
                                    app.ROI_Binary.InteractionsAllowed='none';
                                    app.ROI_NoTail.InteractionsAllowed='none';
                                    app.ROI_Ellipse.InteractionsAllowed='none';
                                    app.ROI.FaceSelectable=0;
                                    app.ROI_Raw.FaceSelectable=0;
                                    app.ROI_Binary.FaceSelectable=0;
                                    app.ROI_NoTail.FaceSelectable=0;
                                    app.ROI_Ellipse.FaceSelectable=0;
                                end
                            end
                        end

                        
                        % Trace

                        if isempty(app.Trace_Window.UIAxes.Children)
                            scatter(app.Trace_Window.UIAxes,xbar,ybar,'.','MarkerFaceColor',app.TraceColor,'MarkerEdgeColor',app.TraceColor)
                        else
                            app.Trace_Window.UIAxes.Children(1).XData = [app.Trace_Window.UIAxes.Children(1).XData xbar];
                            app.Trace_Window.UIAxes.Children(1).YData = [app.Trace_Window.UIAxes.Children(1).YData ybar];
                        end

                        if i >1
                            app.ProgressText.Text = ['Eccentricity: ' num2str(round(rp(v).Eccentricity,2),'%.2f') ' Speed: ' num2str(round(app.Speed(i,:),2),'%.2f') ' ' num2str(real_units_TIFF) '/s; x: ' num2str(round(xdistcoord(i,:),2),'%.2f') ' ' num2str(real_units_TIFF) ' y: ' num2str(round(ydistcoord(i,:),2),'%.2f') ' ' num2str(real_units_TIFF)];
                        end

                    end
                    catch
                    end
                    drawnow
                else
                    % GRAYSCALE TIFF

                    if isfloat(app.Image)

                        if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                            bw_display_image = (app.Image(:,:,i)<changingValue)-(app.Background_Image<changingValue);
                        else
                            bw_display_image = app.Image(:,:,i)-app.Background_Image > changingValue;
                        end
                    else
                        if isa(app.Background_Image,'uint8')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (app.Image(:,:,i)<= 255*changingValue)-(app.Background_Image<= 255*changingValue);
                            else
                                bw_display_image = app.Image(:,:,i)-app.Background_Image >= 255*changingValue;
                            end

                        end
                        if isa(app.Background_Image,'uint16')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (app.Image(:,:,i)<= 65535*changingValue)-(app.Background_Image<= 65535*changingValue);
                            else
                                bw_display_image = app.Image(:,:,i)-app.Background_Image >= 65535*changingValue;
                            end
                        end
                    end

                    % Remove tail
                    se = strel('disk',app.StructuralElementSizeSlider.Value);
                    bw_display_image_NT = imopen(bw_display_image,se);

                    rp = regionprops(bw_display_image_NT,'Orientation', 'MajorAxisLength', ...
                        'MinorAxisLength', 'Eccentricity', 'Centroid','Area');

                    ellipsenum = length(rp); %Number of ellipses detected in frame

                    if ellipsenum < 2
                        input = 1;
                    elseif ellipsenum > 1
                        for ii = 1:1:length(rp)
                            [sizesofellipses(ii)] = rp(ii).MajorAxisLength*rp(ii).MinorAxisLength; %Finds the rectangular area of ellipse
                        end
                        [~, input] = max(sizesofellipses);%Determine input that creates largest ellipse based on rectangular area
                        clear 'sizesofellipses'; %Clears array of rectangular areas b/c next iteriation may have less ellipes, so this ensures it doesn't pick a value from a previous iteriation.
                    end

                    %Display plot of largest ellipse (Used code from Steve Eddins' blog article,"Visualizing regionprops ellipse measurements" % _Steve Eddins_% _Copyright 2010 The MathWorks, Inc)

                    phi = linspace(0,2*pi,50);
                    cosphi = cos(phi);
                    sinphi = sin(phi);
                    if size(rp) > 0
                        try
                        for v = input
                            xbar = rp(v).Centroid(1);
                            ybar = rp(v).Centroid(2);

                            a = rp(v).MajorAxisLength/2;
                            b = rp(v).MinorAxisLength/2;

                            theta = pi*rp(v).Orientation/180;
                            R = [cos(theta)   sin(theta)
                                -sin(theta)   cos(theta)];

                            xy = [a*cosphi; b*sinphi];
                            xy = R*xy;

                            x = xy(1,:) + xbar;
                            y = xy(2,:) + ybar;

                            xdistcoord(i,:) = xbar*(real_width_TIFF/pixel_width);
                            ydistcoord(i,:) = ybar*(real_height_TIFF/pixel_height);

                            if i>1
                                app.Speed(i,:) = sqrt((xdistcoord(i,:)-xdistcoord(i-1,:))^2+(ydistcoord(i,:)-ydistcoord(i-1,:))^2)*app.fps;
                            end
                            app.Eccentricity(i,:) = rp(v).Eccentricity;
                            Orientation(i,:) = rp(v).Orientation;
                            MajorAxisLength(i,:) = rp(v).MajorAxisLength;
                            MinorAxisLength(i,:) = rp(v).MinorAxisLength;
                            Area(i,:) = rp(v).Area;

                            % Display Ellipsed Rodent
                            imshow(bw_display_image,'Parent',app.Video_Window.EllipseAxes)
                            hold(app.Video_Window.EllipseAxes,"on")
                            if size(rp)>0
                                plot(app.Video_Window.EllipseAxes,x,y,'color',app.EllipseColor,'LineWidth',2);
                            end
                            title(app.Video_Window.EllipseAxes,'Draw Ellipse')
                            scatter(app.Video_Window.EllipseAxes,xbar,ybar,'.','MarkerFaceColor',app.CentroidColor,'MarkerEdgeColor',app.CentroidColor)
                            hold(app.Video_Window.EllipseAxes,"off")
    
                            % Display ROIs

                           if ~isempty(app.ROI_Data)
                                for ii = 1:size(app.ROI_Data,1)
                                    if app.ROI_Data(ii,2)=="1"
                                        Position = str2num(char([app.ROI_Data(ii,6:9)]'))';
                                        if sum(isstrprop(app.ROI_Data(ii,5),'digit'))==0
                                            app.ROI_Raw = drawrectangle(app.Video_Window.RawAxes,'Position',Position,'Color',app.ROI_Data(ii,5));
                                            app.ROI_Binary = drawrectangle(app.Video_Window.BinaryAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                            app.ROI_NoTail = drawrectangle(app.Video_Window.NoTailAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                            app.ROI_Ellipse = drawrectangle(app.Video_Window.EllipseAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                        else
                                            app.ROI_Raw = drawrectangle(app.Video_Window.RawAxes,'Position',Position,'Color',str2num(app.ROI_Data(ii,5)));
                                            app.ROI_Binary = drawrectangle(app.Video_Window.BinaryAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                            app.ROI_NoTail = drawrectangle(app.Video_Window.NoTailAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                            app.ROI_Ellipse = drawrectangle(app.Video_Window.EllipseAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                        end
                                        app.ROI_Raw.InteractionsAllowed='none';
                                        app.ROI_Binary.InteractionsAllowed='none';
                                        app.ROI_NoTail.InteractionsAllowed='none';
                                        app.ROI_Ellipse.InteractionsAllowed='none';
                                        app.ROI.FaceSelectable=0;
                                        app.ROI_Raw.FaceSelectable=0;
                                        app.ROI_Binary.FaceSelectable=0;
                                        app.ROI_NoTail.FaceSelectable=0;
                                        app.ROI_Ellipse.FaceSelectable=0;
                                    end
                                end
                            end


                            % Trace
                            
                            if isempty(app.Trace_Window.UIAxes.Children)
                                scatter(app.Trace_Window.UIAxes,xbar,ybar,'.','MarkerFaceColor',app.TraceColor,'MarkerEdgeColor',app.TraceColor)
                            else
                                app.Trace_Window.UIAxes.Children(1).XData = [app.Trace_Window.UIAxes.Children(1).XData xbar];
                                app.Trace_Window.UIAxes.Children(1).YData = [app.Trace_Window.UIAxes.Children(1).YData ybar];
                            end

                            if i >1
                                app.ProgressText.Text = ['Eccentricity: ' num2str(round(rp(v).Eccentricity,2),'%.2f') ' Speed: ' num2str(round(app.Speed(i,:),2),'%.2f') ' ' num2str(real_units_TIFF) '/s; x: ' num2str(round(xdistcoord(i,:),2),'%.2f') ' ' num2str(real_units_TIFF) ' y: ' num2str(round(ydistcoord(i,:),2),'%.2f') ' ' num2str(real_units_TIFF)];
                            end

                        end
                        catch
                        end
                        drawnow
                    end
                end

            else
                %Not TIFF
                pixel_width = app.Image_info.Width;
                pixel_height = app.Image_info.Height;

                if isempty(app.real_width)
                    real_dim = inputdlg({'Enter image/frame width:','Enter image/frame name:','Units:'},'Frame Dimensions',[1 45],{'30','30','cm'});
                    app.real_width = str2double(real_dim{1});
                    app.real_height = str2double(real_dim{2});
                    app.real_units = real_dim{3};
                end

                app.fps = app.Image_info.FrameRate;

                app.ProgressText.Text = 'Loading...';
                app.ProgressText.Visible = "on";

                app.FileInfoText.Text = {['FPS: ' num2str(app.fps)];['width: ' num2str(app.real_width) ' ' app.real_units];['height: ' num2str(app.real_height) ' ' app.real_units]};
                app.FileInfoText.Visible = "on";
            
            
                i = floor(app.TimeSlider.Value*app.fps+1);

                % preallocate
                app.Speed = zeros(size(app.Image_info,1)-1,1);
                app.Eccentricity = zeros(size(app.Image_info,1)-1,1);
                xdistcoord = zeros(size(app.Image_info,1)-1,1);
                ydistcoord = zeros(size(app.Image_info,1)-1,1);
                Orientation = zeros(size(app.Image_info,1)-1,1);
                MajorAxisLength = zeros(size(app.Image_info,1)-1,1);
                MinorAxisLength = zeros(size(app.Image_info,1)-1,1);
                Area = zeros(size(app.Image_info,1)-1,1);

                if size(size(app.Background_Image),2)==3
                % Convert to Binary Image

                if isfloat(app.Image)

                        if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                            bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < changingValue);
                        else
                            bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) > changingValue;
                        end
                    else
                        if isa(app.Background_Image,'uint8')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < 255*changingValue)-(rgb2gray(app.Background_Image) < 255*changingValue);
                            else
                                bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) >= 255*changingValue;
                            end

                        end
                        if isa(app.Background_Image,'uint16')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < 65535*changingValue)-(rgb2gray(app.Background_Image) < 65535*changingValue);
                            else
                                bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) >= 65535*changingValue;
                            end
                        end
                end

                    % Raw Image

                    imshow(app.Image(:,:,:,i),'Parent',app.Video_Window.RawAxes)
                    title(app.Video_Window.RawAxes,'Original Video')
                    
                    % Binary Image

                    imshow(bw_display_image,'Parent',app.Video_Window.BinaryAxes)
                    title(app.Video_Window.BinaryAxes,'Binary Video')
                   
                else
                    % GRAYSCALE

                    % Convert to Binary Image

                    if isfloat(app.Image)

                        if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                            bw_display_image = (app.Image(:,:,i)<changingValue)-(app.Background_Image<changingValue);
                        else
                            bw_display_image = app.Image(:,:,i)-app.Background_Image > changingValue;
                        end
                    else
                        if isa(app.Background_Image,'uint8')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (app.Image(:,:,i)<= 255*changingValue)-(app.Background_Image<= 255*changingValue);
                            else
                                bw_display_image = app.Image(:,:,i)-app.Background_Image >= 255*changingValue;
                            end

                        end
                        if isa(app.Background_Image,'uint16')
                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (app.Image(:,:,i)<= 65535*changingValue)-(app.Background_Image<= 65535*changingValue);
                            else
                                bw_display_image = app.Image(:,:,i)-app.Background_Image >= 65535*changingValue;
                            end
                        end
                   end                             

                    % Raw Image

                    imshow(app.Image(:,:,i),'Parent',app.Video_Window.RawAxes)
                    title(app.Video_Window.RawAxes,'Original Video')
                    % Binary Image

                    imshow(bw_display_image,'Parent',app.Video_Window.BinaryAxes)
                    title(app.Video_Window.BinaryAxes,'Binary Video')

                end

                     % Remove tail
                    se = strel('disk',round(app.StructuralElementSizeSlider.Value));

                    imshow(imopen(bw_display_image,se),'Parent',app.Video_Window.NoTailAxes)
                    title(app.Video_Window.NoTailAxes,'Remove Tail')

                    rp = regionprops(bw_display_image,'Orientation', 'MajorAxisLength', ...
                        'MinorAxisLength', 'Eccentricity', 'Centroid','Area');

                    ellipsenum = length(rp); %Number of ellipses detected in frame

                    if ellipsenum < 2
                        input = 1;
                    elseif ellipsenum > 1
                        for ii = 1:1:length(rp)
                            [sizesofellipses(ii)] = rp(ii).MajorAxisLength*rp(ii).MinorAxisLength; %Finds the rectangular area of ellipse
                        end
                        [~, input] = max(sizesofellipses);%Determine input that creates largest ellipse based on rectangular area
                        clear 'sizesofellipses'; %Clears array of rectangular areas b/c next iteriation may have less ellipes, so this ensures it doesn't pick a value from a previous iteriation.
                    end

                    %Display plot of largest ellipse (Used code from Steve Eddins' blog article,"Visualizing regionprops ellipse measurements" % _Steve Eddins_% _Copyright 2010 The MathWorks, Inc)

                    phi = linspace(0,2*pi,50);
                    cosphi = cos(phi);
                    sinphi = sin(phi);

                    try
                    for v = input
                        xbar = rp(v).Centroid(1);
                        ybar = rp(v).Centroid(2);

                        a = rp(v).MajorAxisLength/2;
                        b = rp(v).MinorAxisLength/2;

                        theta = pi*rp(v).Orientation/180;
                        R = [cos(theta)   sin(theta)
                            -sin(theta)   cos(theta)];

                        xy = [a*cosphi; b*sinphi];
                        xy = R*xy;

                        x = xy(1,:) + xbar;
                        y = xy(2,:) + ybar;

                        xdistcoord(i,:) = xbar*(app.real_width/pixel_width);
                        ydistcoord(i,:) = ybar*(app.real_height/pixel_height);

                        if i>1
                            app.Speed(i,:) = sqrt((xdistcoord(i,:)-xdistcoord(i-1,:))^2+(ydistcoord(i,:)-ydistcoord(i-1,:))^2)*app.fps;
                        end
                        app.Eccentricity(i,:) = rp(v).Eccentricity;
                        Orientation(i,:) = rp(v).Orientation;
                        MajorAxisLength(i,:) = rp(v).MajorAxisLength;
                        MinorAxisLength(i,:) = rp(v).MinorAxisLength;
                        Area(i,:) = rp(v).Area;

                        % Display Ellipsed Rodent
                        imshow(bw_display_image,'Parent',app.Video_Window.EllipseAxes)
                        hold(app.Video_Window.EllipseAxes,"on")
                        if size(rp)>0
                            plot(app.Video_Window.EllipseAxes,x,y,'color',app.EllipseColor,'LineWidth',2);
                        end
                        title(app.Video_Window.EllipseAxes,'Draw Ellipse')
                        scatter(app.Video_Window.EllipseAxes,xbar,ybar,'.','MarkerFaceColor',app.CentroidColor,'MarkerEdgeColor',app.CentroidColor)
                        hold(app.Video_Window.EllipseAxes,"off")

                        % Display ROIs

                        if ~isempty(app.ROI_Data)
                            for ii = 1:size(app.ROI_Data,1)
                                if app.ROI_Data(ii,2)=="1"
                                    Position = str2num(char([app.ROI_Data(ii,6:9)]'))';
                                    if sum(isstrprop(app.ROI_Data(ii,5),'digit'))==0
                                        app.ROI_Raw = drawrectangle(app.Video_Window.RawAxes,'Position',Position,'Color',app.ROI_Data(ii,5));
                                        app.ROI_Binary = drawrectangle(app.Video_Window.BinaryAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                        app.ROI_NoTail = drawrectangle(app.Video_Window.NoTailAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                        app.ROI_Ellipse = drawrectangle(app.Video_Window.EllipseAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                    else
                                        app.ROI_Raw = drawrectangle(app.Video_Window.RawAxes,'Position',Position,'Color',str2num(app.ROI_Data(ii,5)));
                                        app.ROI_Binary = drawrectangle(app.Video_Window.BinaryAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                        app.ROI_NoTail = drawrectangle(app.Video_Window.NoTailAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                        app.ROI_Ellipse = drawrectangle(app.Video_Window.EllipseAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                    end
                                    app.ROI_Raw.InteractionsAllowed='none';
                                    app.ROI_Binary.InteractionsAllowed='none';
                                    app.ROI_NoTail.InteractionsAllowed='none';
                                    app.ROI_Ellipse.InteractionsAllowed='none';
                                    app.ROI.FaceSelectable=0;
                                    app.ROI_Raw.FaceSelectable=0;
                                    app.ROI_Binary.FaceSelectable=0;
                                    app.ROI_NoTail.FaceSelectable=0;
                                    app.ROI_Ellipse.FaceSelectable=0;
                                end
                            end
                        end

                        
                        % Trace
                        
                        if isempty(app.Trace_Window.UIAxes.Children)
                            scatter(app.Trace_Window.UIAxes,xbar,ybar,'.','MarkerFaceColor',app.TraceColor,'MarkerEdgeColor',app.TraceColor)
                        else
                            app.Trace_Window.UIAxes.Children(1).XData = [app.Trace_Window.UIAxes.Children(1).XData xbar];
                            app.Trace_Window.UIAxes.Children(1).YData = [app.Trace_Window.UIAxes.Children(1).YData ybar];
                        end

                        if i >1
                            app.ProgressText.Text = ['Eccentricity:' num2str(rp(v).Eccentricity,'%.2f') ' Speed:' num2str(app.Speed(i,:),'%.2f') ' ' num2str(app.real_units) '/s; x:' num2str(xdistcoord(i,:),'%.2f') ' ' num2str(app.real_units) ' y:' num2str(ydistcoord(i,:),'%.2f') ' ' num2str(app.real_units)];
                        end

                    end
                    catch
                    end
                    drawnow
            end
        end

        % Value changed function: StructuralElementSizeSlider
        function StructuralElementSizeSliderValueChanged(app, event)
            app.StructuralElementSizeSlider.Value = round(app.StructuralElementSizeSlider.Value);
            app.SEThresholdEditField.Value = app.StructuralElementSizeSlider.Value;
            if size(app.Image_info,1)>1
                OpenTiffImage(app)
            else
                OpenVideo(app)
            end
        end

        % Button pushed function: PlayButton
        function PlayButtonPushed(app, event)
            if app.PlayButton.Text == "Play"
                app.PlayButton.Text = "Stop";
                app.PlayButton.Icon = "IconEnd.png";
                app.ResetButton.Visible = 'off';
                app.ResetButton.Enable = 'off';
                app.TimeSlider.Enable = 'off';
                app.LeftArrowTimeSlider.Enable = 'off';
                app.RightArrowTimeSlider.Enable = 'off';

                if  app.Trace_Window.RodentTrackerTraceUIFigure.Visible == "off"
                ClearTraceButtonPushed(app, event)
                end
         
                % Trace
                hold(app.Trace_Window.UIAxes,"on")

                % Analysis
                app.ProgressText.Visible = "on";

                % preallocate
                app.Speed = zeros(size(app.Image_info,1)-1,1);
                app.Eccentricity = zeros(size(app.Image_info,1)-1,1);
                xdistcoord = zeros(size(app.Image_info,1)-1,1);
                ydistcoord = zeros(size(app.Image_info,1)-1,1);
                Orientation = zeros(size(app.Image_info,1)-1,1);
                MajorAxisLength = zeros(size(app.Image_info,1)-1,1);
                MinorAxisLength = zeros(size(app.Image_info,1)-1,1);
                Area = zeros(size(app.Image_info,1)-1,1);

                if size(app.Image_info,1)>1

                    % If TIFF

                    pixel_width = app.Image_info(1).Width;
                    pixel_height = app.Image_info(1).Height;

                    if isempty(app.Image_info(1).XResolution)
                        real_dim = inputdlg({'Enter image/frame width:','Enter image/frame name:','Units:'},'Frame Dimensions',[1 45],{'30','30','cm'});
                        real_width_TIFF = str2double(real_dim{1});
                        real_height_TIFF = str2double(real_dim{2});
                        real_units_TIFF = real_dim{3};
                    else
                        real_width_TIFF = app.Image_info(1).XResolution;
                        real_height_TIFF = app.Image_info(1).YResolution;
                        real_units_TIFF = app.Image_info(1).ResolutionUnit;
                    end

                    for i = floor(app.TimeSlider.Value*app.fps+1):size(app.Image_info,1)-1
                        if app.PlayButton.Text == "Play"
                            break
                        end
                        
                        app.TimeSlider.Value = (i-1)/app.fps;
                        app.TimesEditField.Value = app.TimeSlider.Value;
                        
                        if size(size(app.Background_Image),2) == 3
                            
                            % Convert to Binary Image

                            if isfloat(app.Image)
        
                                if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                    bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < app.BinaryThresholdSlider.Value);
                                else
                                    bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) > app.BinaryThresholdSlider.Value;
                                end
                            else
                                if isa(app.Background_Image,'uint8')
                                    if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                        bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < 255*app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < 255*app.BinaryThresholdSlider.Value);
                                    else
                                        bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) >= 255*app.BinaryThresholdSlider.Value;
                                    end
        
                                end
                                if isa(app.Background_Image,'uint16')
                                    if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                        bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < 65535*app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < 65535*app.BinaryThresholdSlider.Value);
                                    else
                                        bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) >= 65535*app.BinaryThresholdSlider.Value;
                                    end
                                end
                            end

                            % Display Images

                            % Raw Image

                            imshow(app.Image(:,:,:,i),'Parent',app.Video_Window.RawAxes)
                            title(app.Video_Window.RawAxes,'Original Video')
                            % Binary Image

                            imshow(bw_display_image,'Parent',app.Video_Window.BinaryAxes)
                            title(app.Video_Window.BinaryAxes,'Binary Video')
                            % Remove tail
                            se = strel('disk',round(app.StructuralElementSizeSlider.Value));

                            imshow(imopen(bw_display_image,se),'Parent',app.Video_Window.NoTailAxes)
                            title(app.Video_Window.NoTailAxes,'Remove Tail')

                            rp = regionprops(bw_display_image,'Orientation', 'MajorAxisLength', ...
                                'MinorAxisLength', 'Eccentricity', 'Centroid','Area');

                            ellipsenum = length(rp); %Number of ellipses detected in frame

                            if ellipsenum < 2
                                input = 1;
                            elseif ellipsenum > 1
                                for ii = 1:1:length(rp)
                                    [sizesofellipses(ii)] = rp(ii).MajorAxisLength*rp(ii).MinorAxisLength; %Finds the rectangular area of ellipse
                                end
                                [~, input] = max(sizesofellipses);%Determine input that creates largest ellipse based on rectangular area
                                clear 'sizesofellipses'; %Clears array of rectangular areas b/c next iteriation may have less ellipes, so this ensures it doesn't pick a value from a previous iteriation.
                            end

                            %Display plot of largest ellipse (Used code from Steve Eddins' blog article,"Visualizing regionprops ellipse measurements" % _Steve Eddins_% _Copyright 2010 The MathWorks, Inc)

                            phi = linspace(0,2*pi,50);
                            cosphi = cos(phi);
                            sinphi = sin(phi);

                            try
                            for v = input
                                xbar = rp(v).Centroid(1);
                                ybar = rp(v).Centroid(2);

                                a = rp(v).MajorAxisLength/2;
                                b = rp(v).MinorAxisLength/2;

                                theta = pi*rp(v).Orientation/180;
                                R = [cos(theta)   sin(theta)
                                    -sin(theta)   cos(theta)];

                                xy = [a*cosphi; b*sinphi];
                                xy = R*xy;

                                x = xy(1,:) + xbar;
                                y = xy(2,:) + ybar;

                                xdistcoord(i,:) = xbar*(real_width_TIFF/pixel_width);
                                ydistcoord(i,:) = ybar*(real_height_TIFF/pixel_height);

                                if i>1
                                    app.Speed(i,:) = sqrt((xdistcoord(i,:)-xdistcoord(i-1,:))^2+(ydistcoord(i,:)-ydistcoord(i-1,:))^2)*app.fps;
                                end
                                app.Eccentricity(i,:) = rp(v).Eccentricity;
                                Orientation(i,:) = rp(v).Orientation;
                                MajorAxisLength(i,:) = rp(v).MajorAxisLength;
                                MinorAxisLength(i,:) = rp(v).MinorAxisLength;
                                Area(i,:) = rp(v).Area;

                                % Display Ellipsed Rodent
                                imshow(bw_display_image,'Parent',app.Video_Window.EllipseAxes)
                                hold(app.Video_Window.EllipseAxes,"on")
                                if size(rp)>0
                                    plot(app.Video_Window.EllipseAxes,x,y,'color',app.EllipseColor,'LineWidth',2);
                                end
                                title(app.Video_Window.EllipseAxes,'Draw Ellipse')
                                scatter(app.Video_Window.EllipseAxes,xbar,ybar,'.','MarkerFaceColor',app.CentroidColor,'MarkerEdgeColor',app.CentroidColor)
                                hold(app.Video_Window.EllipseAxes,"off")
        
                                % Display ROIs

                                if ~isempty(app.ROI_Data)
                                    for ii = 1:size(app.ROI_Data,1)
                                        if app.ROI_Data(ii,2)=="1"
                                            Position = str2num(char([app.ROI_Data(ii,6:9)]'))';
                                            if sum(isstrprop(app.ROI_Data(ii,5),'digit'))==0
                                                app.ROI_Raw = drawrectangle(app.Video_Window.RawAxes,'Position',Position,'Color',app.ROI_Data(ii,5));
                                                app.ROI_Binary = drawrectangle(app.Video_Window.BinaryAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                                app.ROI_NoTail = drawrectangle(app.Video_Window.NoTailAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                                app.ROI_Ellipse = drawrectangle(app.Video_Window.EllipseAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                            else
                                                app.ROI_Raw = drawrectangle(app.Video_Window.RawAxes,'Position',Position,'Color',str2num(app.ROI_Data(ii,5)));
                                                app.ROI_Binary = drawrectangle(app.Video_Window.BinaryAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                                app.ROI_NoTail = drawrectangle(app.Video_Window.NoTailAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                                app.ROI_Ellipse = drawrectangle(app.Video_Window.EllipseAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                            end
                                            app.ROI_Raw.InteractionsAllowed='none';
                                            app.ROI_Binary.InteractionsAllowed='none';
                                            app.ROI_NoTail.InteractionsAllowed='none';
                                            app.ROI_Ellipse.InteractionsAllowed='none';
                                            app.ROI.FaceSelectable=0;
                                            app.ROI_Raw.FaceSelectable=0;
                                            app.ROI_Binary.FaceSelectable=0;
                                            app.ROI_NoTail.FaceSelectable=0;
                                            app.ROI_Ellipse.FaceSelectable=0;
                                        end
                                    end
                                end


                                % Trace
                                if isempty(app.Trace_Window.UIAxes.Children)
                                    scatter(app.Trace_Window.UIAxes,xbar,ybar,'.','MarkerFaceColor',app.TraceColor,'MarkerEdgeColor',app.TraceColor)
                                else
                                    app.Trace_Window.UIAxes.Children(1).XData = [app.Trace_Window.UIAxes.Children(1).XData xbar];
                                    app.Trace_Window.UIAxes.Children(1).YData = [app.Trace_Window.UIAxes.Children(1).YData ybar];
                                end

                                if i >1
                                    app.ProgressText.Text = ['Eccentricity: ' num2str(round(rp(v).Eccentricity,2),'%.2f') ' Speed: ' num2str(round(app.Speed(i,:),2),'%.2f') ' ' num2str(real_units_TIFF) '/s; x: ' num2str(round(xdistcoord(i,:),2),'%.2f') ' ' num2str(real_units_TIFF) ' y: ' num2str(round(ydistcoord(i,:),2),'%.2f') ' ' num2str(real_units_TIFF)];
                                end
                            end
                            catch
                            end
                            drawnow
                        else
                            % GRAYSCALE TIFF

                            % Convert to Binary Image

                            if isfloat(app.Image)
        
                                if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                    bw_display_image = (app.Image(:,:,i)<app.BinaryThresholdSlider.Value)-(app.Background_Image<app.BinaryThresholdSlider.Value);%app.Image(:,:,i)-app.Background_Image < app.BinaryThresholdSlider.Value;
                                else
                                    bw_display_image = app.Image(:,:,i)-app.Background_Image > app.BinaryThresholdSlider.Value;
                                end
                            else
                                if isa(app.Background_Image,'uint8')
                                    if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                        bw_display_image = (app.Image(:,:,i)<= 255*app.BinaryThresholdSlider.Value)-(app.Background_Image<= 255*app.BinaryThresholdSlider.Value);%app.Image(:,:,i)-app.Background_Image <= 255*app.BinaryThresholdSlider.Value;
                                    else
                                        bw_display_image = app.Image(:,:,i)-app.Background_Image >= 255*app.BinaryThresholdSlider.Value;
                                    end
        
                                end
                                if isa(app.Background_Image,'uint16')
                                    if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                        bw_display_image = (app.Image(:,:,i)<= 65535*app.BinaryThresholdSlider.Value)-(app.Background_Image<= 65535*app.BinaryThresholdSlider.Value);%app.Image(:,:,i)-app.Background_Image <= 65535*app.BinaryThresholdSlider.Value;
                                    else
                                        bw_display_image = app.Image(:,:,i)-app.Background_Image >= 65535*app.BinaryThresholdSlider.Value;
                                    end
                                end
                            end

                            % Display Images

                            % Raw Image
                            imshow(app.Image(:,:,i),'Parent',app.Video_Window.RawAxes)
                            title(app.Video_Window.RawAxes,'Original Video')

                            % Binary Image
                            imshow(bw_display_image,'Parent',app.Video_Window.BinaryAxes)
                            title(app.Video_Window.BinaryAxes,'Binary Video')

                            % Remove tail
                            se = strel('disk',round(app.StructuralElementSizeSlider.Value));
                            bw_display_image_NT = imopen(bw_display_image,se);

                            imshow(bw_display_image_NT,'Parent',app.Video_Window.NoTailAxes)
                            title(app.Video_Window.NoTailAxes,'Remove Tail')
                            rp = regionprops(bw_display_image_NT,'Orientation', 'MajorAxisLength', ...
                                'MinorAxisLength', 'Eccentricity', 'Centroid','Area');

                            ellipsenum = length(rp); %Number of ellipses detected in frame

                            if ellipsenum < 2
                                input = 1;
                            elseif ellipsenum > 1
                                for ii = 1:1:length(rp)
                                    [sizesofellipses(ii)] = rp(ii).MajorAxisLength*rp(ii).MinorAxisLength; %Finds the rectangular area of ellipse
                                end
                                [~, input] = max(sizesofellipses);%Determine input that creates largest ellipse based on rectangular area
                                clear 'sizesofellipses'; %Clears array of rectangular areas b/c next iteriation may have less ellipes, so this ensures it doesn't pick a value from a previous iteriation.
                            end

                            %Display plot of largest ellipse (Used code from Steve Eddins' blog article,"Visualizing regionprops ellipse measurements" % _Steve Eddins_% _Copyright 2010 The MathWorks, Inc)

                            phi = linspace(0,2*pi,50);
                            cosphi = cos(phi);
                            sinphi = sin(phi);

                            try
                            for v = input
                                xbar = rp(v).Centroid(1);
                                ybar = rp(v).Centroid(2);

                                a = rp(v).MajorAxisLength/2;
                                b = rp(v).MinorAxisLength/2;

                                theta = pi*rp(v).Orientation/180;
                                R = [cos(theta)   sin(theta)
                                    -sin(theta)   cos(theta)];

                                xy = [a*cosphi; b*sinphi];
                                xy = R*xy;

                                x = xy(1,:) + xbar;
                                y = xy(2,:) + ybar;

                                xdistcoord(i,:) = xbar*(real_width_TIFF/pixel_width);
                                ydistcoord(i,:) = ybar*(real_height_TIFF/pixel_height);

                                if i>1
                                    app.Speed(i,:) = sqrt((xdistcoord(i,:)-xdistcoord(i-1,:))^2+(ydistcoord(i,:)-ydistcoord(i-1,:))^2)*app.fps;
                                end
                                app.Eccentricity(i,:) = rp(v).Eccentricity;
                                Orientation(i,:) = rp(v).Orientation;
                                MajorAxisLength(i,:) = rp(v).MajorAxisLength;
                                MinorAxisLength(i,:) = rp(v).MinorAxisLength;
                                Area(i,:) = rp(v).Area;

                                % Display Ellipsed Rodent
                                imshow(bw_display_image,'Parent',app.Video_Window.EllipseAxes)
                                hold(app.Video_Window.EllipseAxes,"on")
                                if size(rp)>0
                                    plot(app.Video_Window.EllipseAxes,x,y,'color',app.EllipseColor,'LineWidth',2);
                                end
                                title(app.Video_Window.EllipseAxes,'Draw Ellipse')
                                scatter(app.Video_Window.EllipseAxes,xbar,ybar,'.','MarkerFaceColor',app.CentroidColor,'MarkerEdgeColor',app.CentroidColor,'SizeData',40)
                                scatter(app.Video_Window.EllipseAxes,x(1),y(1),'.','MarkerFaceColor',app.HeadpointColor,'MarkerEdgeColor',app.HeadpointColor,'SizeData',40)
                                scatter(app.Video_Window.EllipseAxes,x(end/2),y(end/2),'.','MarkerFaceColor',app.TailpointColor,'MarkerEdgeColor',app.TailpointColor,'SizeData',40)
                                hold(app.Video_Window.EllipseAxes,"off")
                               
                                % Display ROIs
        
                                if ~isempty(app.ROI_Data)
                                    for ii = 1:size(app.ROI_Data,1)
                                        if app.ROI_Data(ii,2)=="1"
                                            Position = str2num(char([app.ROI_Data(ii,6:9)]'))';
                                            if sum(isstrprop(app.ROI_Data(ii,5),'digit'))==0
                                                app.ROI_Raw = drawrectangle(app.Video_Window.RawAxes,'Position',Position,'Color',app.ROI_Data(ii,5));
                                                app.ROI_Binary = drawrectangle(app.Video_Window.BinaryAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                                app.ROI_NoTail = drawrectangle(app.Video_Window.NoTailAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                                app.ROI_Ellipse = drawrectangle(app.Video_Window.EllipseAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                            else
                                                app.ROI_Raw = drawrectangle(app.Video_Window.RawAxes,'Position',Position,'Color',str2num(app.ROI_Data(ii,5)));
                                                app.ROI_Binary = drawrectangle(app.Video_Window.BinaryAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                                app.ROI_NoTail = drawrectangle(app.Video_Window.NoTailAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                                app.ROI_Ellipse = drawrectangle(app.Video_Window.EllipseAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                            end
                                            app.ROI_Raw.InteractionsAllowed='none';
                                            app.ROI_Binary.InteractionsAllowed='none';
                                            app.ROI_NoTail.InteractionsAllowed='none';
                                            app.ROI_Ellipse.InteractionsAllowed='none';
                                            app.ROI.FaceSelectable=0;
                                            app.ROI_Raw.FaceSelectable=0;
                                            app.ROI_Binary.FaceSelectable=0;
                                            app.ROI_NoTail.FaceSelectable=0;
                                            app.ROI_Ellipse.FaceSelectable=0;
                                        end
                                    end
                                end

                                % Display Trace
                                if isempty(app.Trace_Window.UIAxes.Children)
                                    scatter(app.Trace_Window.UIAxes,xbar,ybar,'.','MarkerFaceColor',app.TraceColor,'MarkerEdgeColor',app.TraceColor)
                                else
                                    app.Trace_Window.UIAxes.Children(1).XData = [app.Trace_Window.UIAxes.Children(1).XData xbar];
                                    app.Trace_Window.UIAxes.Children(1).YData = [app.Trace_Window.UIAxes.Children(1).YData ybar];
                                end

                                if i >1
                                    app.ProgressText.Text = ['Eccentricity: ' num2str(round(rp(v).Eccentricity,2),'%.2f') ' Speed: ' num2str(round(app.Speed(i,:),2),'%.2f') ' ' num2str(real_units_TIFF) '/s; x: ' num2str(round(xdistcoord(i,:),2),'%.2f') ' ' num2str(real_units_TIFF) ' y: ' num2str(round(ydistcoord(i,:),2),'%.2f') ' ' num2str(real_units_TIFF)];
                                end
                            end
                            catch
                            end
                            drawnow
                        end
                    end

                else

                    % If not TIFF
                    if isempty(app.real_width)
                        real_dim = inputdlg({'Enter image/frame width:','Enter image/frame name:','Units:'},'Frame Dimensions',[1 45],{'30','30','cm'});
                        app.real_width = str2double(real_dim{1});
                        app.real_height = str2double(real_dim{2});
                        app.real_units = real_dim{3};
                    end
 
                    pixel_width = app.Image_info.Width;
                    pixel_height = app.Image_info.Height;

                    for i = floor(app.TimeSlider.Value*app.fps+1):app.Image_info.NumFrames-1
                        if app.PlayButton.Text == "Play"
                            break
                        end

                        app.TimeSlider.Value = (i-1)/app.fps;
                        app.TimesEditField.Value = app.TimeSlider.Value;

                        if size(size(app.Background_Image),2) == 3

                            % Convert to Binary Image

                            if isfloat(app.Image)
        
                                if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                    bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < app.BinaryThresholdSlider.Value);
                                else
                                    bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) > app.BinaryThresholdSlider.Value;
                                end
                            else
                                if isa(app.Background_Image,'uint8')
                                    if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                        bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < 255*app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < 255*app.BinaryThresholdSlider.Value);
                                    else
                                        bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) >= 255*app.BinaryThresholdSlider.Value;
                                    end
        
                                end
                                if isa(app.Background_Image,'uint16')
                                    if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                        bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < 65535*app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < 65535*app.BinaryThresholdSlider.Value);
                                    else
                                        bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) >= 65535*app.BinaryThresholdSlider.Value;
                                    end
                                end
                            end
 
                        % Display Images

                            % Raw Image

                            imshow(app.Image(:,:,:,i),'Parent',app.Video_Window.RawAxes)
                            title(app.Video_Window.RawAxes,'Original Video')
                            % Binary Image

                            imshow(bw_display_image,'Parent',app.Video_Window.BinaryAxes)
                            title(app.Video_Window.BinaryAxes,'Binary Video')
                            % Remove tail
                            se = strel('disk',round(app.StructuralElementSizeSlider.Value));

                            imshow(imopen(bw_display_image,se),'Parent',app.Video_Window.NoTailAxes)
                            title(app.Video_Window.NoTailAxes,'Remove Tail')

                            rp = regionprops(bw_display_image,'Orientation', 'MajorAxisLength', ...
                                'MinorAxisLength', 'Eccentricity', 'Centroid','Area');

                            ellipsenum = length(rp); %Number of ellipses detected in frame

                            if ellipsenum < 2
                                input = 1;
                            elseif ellipsenum > 1
                                for ii = 1:1:length(rp)
                                    [sizesofellipses(ii)] = rp(ii).MajorAxisLength*rp(ii).MinorAxisLength; %Finds the rectangular area of ellipse
                                end
                                [~, input] = max(sizesofellipses);%Determine input that creates largest ellipse based on rectangular area
                                clear 'sizesofellipses'; %Clears array of rectangular areas b/c next iteriation may have less ellipes, so this ensures it doesn't pick a value from a previous iteriation.
                            end

                            %Display plot of largest ellipse (Used code from Steve Eddins' blog article,"Visualizing regionprops ellipse measurements" % _Steve Eddins_% _Copyright 2010 The MathWorks, Inc)

                            phi = linspace(0,2*pi,50);
                            cosphi = cos(phi);
                            sinphi = sin(phi);
                            try
                            for v = input
                                xbar = rp(v).Centroid(1);
                                ybar = rp(v).Centroid(2);

                                a = rp(v).MajorAxisLength/2;
                                b = rp(v).MinorAxisLength/2;

                                theta = pi*rp(v).Orientation/180;
                                R = [cos(theta)   sin(theta)
                                    -sin(theta)   cos(theta)];

                                xy = [a*cosphi; b*sinphi];
                                xy = R*xy;

                                x = xy(1,:) + xbar;
                                y = xy(2,:) + ybar;

                                xdistcoord(i,:) = xbar*(app.real_width/pixel_width);
                                ydistcoord(i,:) = ybar*(app.real_height/pixel_height);

                                if i>1
                                    app.Speed(i,:) = sqrt((xdistcoord(i,:)-xdistcoord(i-1,:))^2+(ydistcoord(i,:)-ydistcoord(i-1,:))^2)*app.fps;
                                end
                                app.Eccentricity(i,:) = rp(v).Eccentricity;
                                Orientation(i,:) = rp(v).Orientation;
                                MajorAxisLength(i,:) = rp(v).MajorAxisLength;
                                MinorAxisLength(i,:) = rp(v).MinorAxisLength;
                                Area(i,:) = rp(v).Area;

                                % Display Ellipsed Rodent
                                imshow(bw_display_image,'Parent',app.Video_Window.EllipseAxes)
                                hold(app.Video_Window.EllipseAxes,"on")
                                if size(rp)>0
                                    plot(app.Video_Window.EllipseAxes,x,y,'color',app.EllipseColor,'LineWidth',2);
                                end
                                title(app.Video_Window.EllipseAxes,'Draw Ellipse')
                                scatter(app.Video_Window.EllipseAxes,xbar,ybar,'.','MarkerFaceColor',app.CentroidColor,'MarkerEdgeColor',app.CentroidColor)
                                hold(app.Video_Window.EllipseAxes,"off")

                                % Display ROIs
        
                                if ~isempty(app.ROI_Data)
                                    for ii = 1:size(app.ROI_Data,1)
                                        if app.ROI_Data(ii,2)=="1"
                                            Position = str2num(char([app.ROI_Data(ii,6:9)]'))';
                                            if sum(isstrprop(app.ROI_Data(ii,5),'digit'))==0
                                                app.ROI_Raw = drawrectangle(app.Video_Window.RawAxes,'Position',Position,'Color',app.ROI_Data(ii,5));
                                                app.ROI_Binary = drawrectangle(app.Video_Window.BinaryAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                                app.ROI_NoTail = drawrectangle(app.Video_Window.NoTailAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                                app.ROI_Ellipse = drawrectangle(app.Video_Window.EllipseAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                                            else
                                                app.ROI_Raw = drawrectangle(app.Video_Window.RawAxes,'Position',Position,'Color',str2num(app.ROI_Data(ii,5)));
                                                app.ROI_Binary = drawrectangle(app.Video_Window.BinaryAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                                app.ROI_NoTail = drawrectangle(app.Video_Window.NoTailAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                                app.ROI_Ellipse = drawrectangle(app.Video_Window.EllipseAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                                            end
                                            app.ROI_Raw.InteractionsAllowed='none';
                                            app.ROI_Binary.InteractionsAllowed='none';
                                            app.ROI_NoTail.InteractionsAllowed='none';
                                            app.ROI_Ellipse.InteractionsAllowed='none';
                                            app.ROI.FaceSelectable=0;
                                            app.ROI_Raw.FaceSelectable=0;
                                            app.ROI_Binary.FaceSelectable=0;
                                            app.ROI_NoTail.FaceSelectable=0;
                                            app.ROI_Ellipse.FaceSelectable=0;
                                        end
                                    end
                                end

        
                                % Trace
                                
                                if isempty(app.Trace_Window.UIAxes.Children)
                                    scatter(app.Trace_Window.UIAxes,xbar,ybar,'.','MarkerFaceColor',app.TraceColor,'MarkerEdgeColor',app.TraceColor)
                                else
                                    app.Trace_Window.UIAxes.Children(1).XData = [app.Trace_Window.UIAxes.Children(1).XData xbar];
                                    app.Trace_Window.UIAxes.Children(1).YData = [app.Trace_Window.UIAxes.Children(1).YData ybar];
                                end

                                if i >1
                                    app.ProgressText.Text = ['Eccentricity: ' num2str(round(rp(v).Eccentricity,2),'%.2f') ' Speed: ' num2str(round(app.Speed(i,:),2),'%.2f') ' ' num2str(app.real_units) '/s; x: ' num2str(round(xdistcoord(i,:),2),'%.2f') ' ' num2str(app.real_units) ' y: ' num2str(round(ydistcoord(i,:),2),'%.2f') ' ' num2str(app.real_units)];
                                end

                            end
                            catch
                            end
                            drawnow
                        else
                            % GRAYSCALE TIFF

                            % Convert to Binary Image

                            if isfloat(app.Image)
        
                                if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                    bw_display_image = (app.Image(:,:,i)<app.BinaryThresholdSlider.Value)-(app.Background_Image<app.BinaryThresholdSlider.Value);
                                else
                                    bw_display_image = app.Image(:,:,i)-app.Background_Image > app.BinaryThresholdSlider.Value;
                                end
                            else
                                if isa(app.Background_Image,'uint8')
                                    if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                        bw_display_image = (app.Image(:,:,i)<= 255*app.BinaryThresholdSlider.Value)-(app.Background_Image<= 255*app.BinaryThresholdSlider.Value);
                                    else
                                        bw_display_image = app.Image(:,:,i)-app.Background_Image >= 255*app.BinaryThresholdSlider.Value;
                                    end
        
                                end
                                if isa(app.Background_Image,'uint16')
                                    if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                        bw_display_image = (app.Image(:,:,i)<= 65535*app.BinaryThresholdSlider.Value)-(app.Background_Image<= 65535*app.BinaryThresholdSlider.Value);
                                    else
                                        bw_display_image = app.Image(:,:,i)-app.Background_Image >= 65535*app.BinaryThresholdSlider.Value;
                                    end
                                end
                            end

                            % Display Images

                            % Raw Image
                            imshow(app.Image(:,:,i),'Parent',app.Video_Window.RawAxes)
                            title(app.Video_Window.RawAxes,'Original Video')

                            % Binary Image
                            imshow(bw_display_image,'Parent',app.Video_Window.BinaryAxes)
                            title(app.Video_Window.BinaryAxes,'Binary Video')

                            % Remove tail
                            se = strel('disk',round(app.StructuralElementSizeSlider.Value));
                            bw_display_image_NT = imopen(bw_display_image,se);

                            imshow(bw_display_image_NT,'Parent',app.Video_Window.NoTailAxes)
                            title(app.Video_Window.NoTailAxes,'Remove Tail')
                            rp = regionprops(bw_display_image_NT,'Orientation', 'MajorAxisLength', ...
                                'MinorAxisLength', 'Eccentricity', 'Centroid','Area');

                            ellipsenum = length(rp); %Number of ellipses detected in frame

                            if ellipsenum < 2
                                input = 1;
                            elseif ellipsenum > 1
                                for ii = 1:1:length(rp)
                                    [sizesofellipses(ii)] = rp(ii).MajorAxisLength*rp(ii).MinorAxisLength; %Finds the rectangular area of ellipse
                                end
                                [~, input] = max(sizesofellipses);%Determine input that creates largest ellipse based on rectangular area
                                clear 'sizesofellipses'; %Clears array of rectangular areas b/c next iteriation may have less ellipes, so this ensures it doesn't pick a value from a previous iteriation.
                            end

                            %Display plot of largest ellipse (Used code from Steve Eddins' blog article,"Visualizing regionprops ellipse measurements" % _Steve Eddins_% _Copyright 2010 The MathWorks, Inc)

                            phi = linspace(0,2*pi,50);
                            cosphi = cos(phi);
                            sinphi = sin(phi);
                            
                            try
                            for v = input
                                xbar = rp(v).Centroid(1);
                                ybar = rp(v).Centroid(2);

                                a = rp(v).MajorAxisLength/2;
                                b = rp(v).MinorAxisLength/2;

                                theta = pi*rp(v).Orientation/180;
                                R = [cos(theta)   sin(theta)
                                    -sin(theta)   cos(theta)];

                                xy = [a*cosphi; b*sinphi];
                                xy = R*xy;

                                x = xy(1,:) + xbar;
                                y = xy(2,:) + ybar;

                                xdistcoord(i,:) = xbar*(app.real_width/pixel_width);
                                ydistcoord(i,:) = ybar*(app.real_height/pixel_height);

                                if i>1
                                    app.Speed(i,:) = sqrt((xdistcoord(i,:)-xdistcoord(i-1,:))^2+(ydistcoord(i,:)-ydistcoord(i-1,:))^2)*app.fps;
                                end
                                app.Eccentricity(i,:) = rp(v).Eccentricity;
                                Orientation(i,:) = rp(v).Orientation;
                                MajorAxisLength(i,:) = rp(v).MajorAxisLength;
                                MinorAxisLength(i,:) = rp(v).MinorAxisLength;
                                Area(i,:) = rp(v).Area;

                                % Display Ellipsed Rodent
                                imshow(bw_display_image,'Parent',app.Video_Window.EllipseAxes)
                                hold(app.Video_Window.EllipseAxes,"on")
                                if size(rp)>0
                                    plot(app.Video_Window.EllipseAxes,x,y,'color',app.EllipseColor,'LineWidth',2);
                                end
                                title(app.Video_Window.EllipseAxes,'Draw Ellipse')
                                scatter(app.Video_Window.EllipseAxes,xbar,ybar,'.','MarkerFaceColor',app.CentroidColor,'MarkerEdgeColor',app.CentroidColor)
                                hold(app.Video_Window.EllipseAxes,"off")

                                % Display Trace

                                if isempty(app.Trace_Window.UIAxes.Children)
                                    scatter(app.Trace_Window.UIAxes,xbar,ybar,'.','MarkerFaceColor',app.TraceColor,'MarkerEdgeColor',app.TraceColor)
                                else
                                    app.Trace_Window.UIAxes.Children(1).XData = [app.Trace_Window.UIAxes.Children(1).XData xbar];
                                    app.Trace_Window.UIAxes.Children(1).YData = [app.Trace_Window.UIAxes.Children(1).YData ybar];
                                end

                                if i >1
                                    app.ProgressText.Text = ['Eccentricity: ' num2str(round(rp(v).Eccentricity,2),'%.2f') ' Speed: ' num2str(round(app.Speed(i,:),2),'%.2f') ' ' num2str(app.real_units) '/s; x: ' num2str(round(xdistcoord(i,:),2),'%.2f') ' ' num2str(app.real_units) ' y: ' num2str(round(ydistcoord(i,:),2),'%.2f') ' ' num2str(app.real_units)];
                                end
                            end
                            catch
                                Disp(['Rodent Not Detected on frame ' num2str(i)])
                            end
                            drawnow
                        end

                    end
                end

            else
                app.PlayButton.Text = "Play";
                app.PlayButton.Icon = "IconPlay.png";
                app.ResetButton.Visible = "on";
                app.ResetButton.Enable = "on";
                app.TimeSlider.Enable = "on";
                app.LeftArrowTimeSlider.Enable = "on";
                app.RightArrowTimeSlider.Enable = "on";
            end
        end

        % Value changed function: DropDown
        function DropDownValueChanged(app, event)
            app.filename = app.DropDown.Value;
            [app.Image, app.Background_Image, app.Image_info] = Extract_video_matrix(fullfile(app.folder,app.filename));

            imshow(zeros(size(app.Background_Image)),"Parent",app.Video_Window.RawAxes)
            imshow(zeros(size(app.Background_Image)),"Parent",app.Video_Window.BinaryAxes)
            imshow(zeros(size(app.Background_Image)),"Parent",app.Video_Window.NoTailAxes)
            imshow(zeros(size(app.Background_Image)),"Parent",app.Video_Window.EllipseAxes)

                if size(app.Image_info,1)>1
                    OpenTiffImage(app)
                else
                    OpenVideo(app)
                end

            ClearTraceButtonPushed(app)
            app.ProgressText.Text = 'Done';
        end

        % Button pushed function: ClearTraceButton
        function ClearTraceButtonPushed(app, event)
            delete(app.Trace_Window.UIAxes)
            % Create UIAxes
            app.Trace_Window.UIAxes = uiaxes(app.Trace_Window.RodentTrackerTraceUIFigure);
            app.Trace_Window.UIAxes.PlotBoxAspectRatio = [1 1 1];
            app.Trace_Window.UIAxes.XLim = [0 255];
            app.Trace_Window.UIAxes.YLim = [0 255];
            app.Trace_Window.UIAxes.ZLim = [0 1];
            app.Trace_Window.UIAxes.XTick = [];
            app.Trace_Window.UIAxes.YTick = [];
            app.Trace_Window.UIAxes.ZTick = [];
            app.Trace_Window.UIAxes.Color = [0 0 0];
            app.Trace_Window.UIAxes.TickDir = 'none';
            app.Trace_Window.UIAxes.Position = [0 0 400 400];
            axis(app.Trace_Window.UIAxes,'ij')
            app.Trace_Window.RodentTrackerTraceUIFigure.Visible ="on";
        end

        % Close request function: RodentTrackerUIFigure
        function RodentTrackerUIFigureCloseRequest(app, event)
            delete(app.Trace_Window)
            delete(app.Video_Window.ROI_Window)
            delete(app.Video_Window)
            delete(app.Spreadsheet_Window)
            delete(app.Background_Window)
            delete(app.SAP_Window)
            delete(app.ROI_Results_Window)
            
            delete(app)
            delete(gcf)
            delete(gcf)
            delete(gcf)
%             close  all
        end

        % Menu selected function: LoadVideoMenu
        function LoadVideoMenuSelected(app, event)
            LoadVideoButtonPushed(app)
        end

        % Button pushed function: AnalyzeButton
        function AnalyzeButtonPushed(app, event)
            app2 = AnalysisSetup;

            uiwait(app2.AnalysisVideoSettingsUIFigure);

            app.Video_Window.RodentTrackerAnalysisPreviewUIFigure.Visible ="on";
            app.Trace_Window.RodentTrackerTraceUIFigure.Visible ="on";
            app.Spreadsheet_Window.RodentTrackerSpreadsheetUIFigure.Visible ="on";
           
%             app2.AnalysisVideoSettingsUIFigure.Units = 'normalized';
%             app2.AnalysisVideoSettingsUIFigure.Position(1) = 0.40;
%             app2.AnalysisVideoSettingsUIFigure.Position(2) = 0.40;
%             app2.AnalysisVideoSettingsUIFigure.Units = 'pixels';

            % Image,Background_Image,Image_info

            app.ProgressText.Visible = 'off';

            ap_fps = app2.FPSEditField_Tracker.Value;
            tr_fps = app2.FPSEditField_Trace.Value;

            %If Tfig Empty

            % Trace
            app.Trace_Window.UIAxes.XLim = [0 size(app.Background_Image,1)];
            app.Trace_Window.UIAxes.YLim = [0 size(app.Background_Image,2)];
            app.Trace_Window.UIAxes.Units = 'normalized';
            app.Trace_Window.UIAxes.InnerPosition = [0 0 1 1];
            app.Trace_Window.UIAxes.Units = 'pixels';
            imshow(zeros(size(app.Background_Image)),"Parent",app.Trace_Window.UIAxes)
            hold(app.Trace_Window.UIAxes,"on")

            % Analysis

            % preallocate
            app.Speed = zeros(size(app.Image_info,1)-1,1);
            app.Eccentricity = zeros(size(app.Image_info,1)-1,1);
            xdistcoord = zeros(size(app.Image_info,1)-1,1);
            ydistcoord = zeros(size(app.Image_info,1)-1,1);
            Orientation = zeros(size(app.Image_info,1)-1,1);
            MajorAxisLength = zeros(size(app.Image_info,1)-1,1);
            MinorAxisLength = zeros(size(app.Image_info,1)-1,1);
            Area = zeros(size(app.Image_info,1)-1,1);

            if size(app.Image_info,1)>1
                % If TIFF
                files = dir(fullfile(app.folder,'*.tif'));
                app.DropDown.Items = {files.name};
                app.DropDown.Value = app.filename;
                pixel_width = app.Image_info(1).Width;
                pixel_height = app.Image_info(1).Height;

                app.Trace_Window.UIAxes.XLim = [0 app.Image_info(1).Width];
                app.Trace_Window.UIAxes.YLim = [0 app.Image_info(1).Height];

                if isempty(app.Image_info(1).XResolution)
                    real_dim = inputdlg({'Enter image/frame width:','Enter image/frame name:','Units:'},'Frame Dimensions',[1 45],{'30','30','cm'});
                    real_width_TIFF = str2double(real_dim{1});
                    real_height_TIFF = str2double(real_dim{2});
                    real_units_TIFF = real_dim{3};
                    app.Image_info(1).XResolution = real_width_TIFF;
                    app.Image_info(1).YResolution = real_height_TIFF;
                    app.Image_info(1).ResolutionUnit = real_units_TIFF;
                else
                    real_width_TIFF = app.Image_info(1).XResolution;
                    real_height_TIFF = app.Image_info(1).YResolution;
                    real_units_TIFF = app.Image_info(1).ResolutionUnit;
                end

                %                 app.TimeSlider.Limits(2)=app.Image_info(1).Duration;

                app.ProgressText.Text = 'Analyzing...';
                app.ProgressText.Visible = "on";

                app.FileInfoText.Text = {['FPS: ' num2str(app.fps)];['width: ' num2str(real_width_TIFF) ' ' real_units_TIFF];['height: ' num2str(real_height_TIFF) ' ' real_units_TIFF]};
                app.FileInfoText.Visible = "on";

                d = uiprogressdlg(app.RodentTrackerUIFigure,'Title','Analyzing Data Please Wait',...
                    'Message','Analyzing...','Icon','RodentTrackerIcon.png');

                for i = 1:size(app.Image_info,1)-1 %i = floor(app.TimeSlider.Value*app.fps+1);

                    %                     app.ProgressText.Text = ['Analyzing... ' num2str(round(100*(i/(size(app.Image_info,1)-1)),2),"%.2f") '%'];

                    d.Value = (i/(size(app.Image_info,1)-1));
                    d.Message = ['Analyzing... ' num2str(round(100*(i/(size(app.Image_info,1)-1)),2),"%.2f") '%'];


                    if size(size(app.Background_Image),2) == 3
                        % Convert to Binary Image

                        if isfloat(app.Image)

                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < app.BinaryThresholdSlider.Value);
                            else
                                bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) > app.BinaryThresholdSlider.Value;
                            end
                        else
                            if isa(app.Background_Image,'uint8')
                                if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                    bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < 255*app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < 255*app.BinaryThresholdSlider.Value);
                                else
                                    bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) >= 255*app.BinaryThresholdSlider.Value;
                                end

                            end
                            if isa(app.Background_Image,'uint16')
                                if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                    bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < 65535*app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < 65535*app.BinaryThresholdSlider.Value);
                                else
                                    bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) >= 65535*app.BinaryThresholdSlider.Value;
                                end
                            end
                        end
                    else
                        % GRAYSCALE TIFF

                        % Convert to Binary Image

                        if isfloat(app.Image)

                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (app.Image(:,:,i)<app.BinaryThresholdSlider.Value)-(app.Background_Image<app.BinaryThresholdSlider.Value);
                            else
                                bw_display_image = app.Image(:,:,i)-app.Background_Image > app.BinaryThresholdSlider.Value;
                            end
                        else
                            if isa(app.Background_Image,'uint8')
                                if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                    bw_display_image = (app.Image(:,:,i)<= 255*app.BinaryThresholdSlider.Value)-(app.Background_Image<= 255*app.BinaryThresholdSlider.Value);
                                else
                                    bw_display_image = app.Image(:,:,i)-app.Background_Image >= 255*app.BinaryThresholdSlider.Value;
                                end

                            end
                            if isa(app.Background_Image,'uint16')
                                if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                    bw_display_image = (app.Image(:,:,i)<= 65535*app.BinaryThresholdSlider.Value)-(app.Background_Image<= 65535*app.BinaryThresholdSlider.Value);
                                else
                                    bw_display_image = app.Image(:,:,i)-app.Background_Image >= 65535*app.BinaryThresholdSlider.Value;
                                end
                            end
                        end
                    end


                    % Remove tail
                    se = strel('disk',round(app.StructuralElementSizeSlider.Value));
                    bw_display_image_NT = imopen(bw_display_image,se);
                    rp = regionprops(bw_display_image,'Orientation', 'MajorAxisLength', ...
                        'MinorAxisLength', 'Eccentricity', 'Centroid','Area');

                    ellipsenum = length(rp); %Number of ellipses detected in frame

                    if ellipsenum < 2
                        input = 1;
                    elseif ellipsenum > 1
                        for ii = 1:1:length(rp)
                            [sizesofellipses(ii)] = rp(ii).MajorAxisLength*rp(ii).MinorAxisLength; %Finds the rectangular area of ellipse
                        end
                        [~, input] = max(sizesofellipses);%Determine input that creates largest ellipse based on rectangular area
                        clear 'sizesofellipses'; %Clears array of rectangular areas b/c next iteriation may have less ellipes, so this ensures it doesn't pick a value from a previous iteriation.
                    end

                    %Display plot of largest ellipse (Used code from Steve Eddins' blog article,"Visualizing regionprops ellipse measurements" % _Steve Eddins_% _Copyright 2010 The MathWorks, Inc)

                    phi = linspace(0,2*pi,50);
                    cosphi = cos(phi);
                    sinphi = sin(phi);

                    try
                        for v = input
                            xbar = rp(v).Centroid(1);
                            ybar = rp(v).Centroid(2);

                            a = rp(v).MajorAxisLength/2;
                            b = rp(v).MinorAxisLength/2;

                            theta = pi*rp(v).Orientation/180;
                            R = [cos(theta)   sin(theta)
                                -sin(theta)   cos(theta)];

                            xy = [a*cosphi; b*sinphi];
                            xy = R*xy;

                            x = xy(1,:) + xbar;
                            y = xy(2,:) + ybar;

                            xdistcoord(i,:) = xbar*(real_width_TIFF/pixel_width);
                            ydistcoord(i,:) = ybar*(real_height_TIFF/pixel_height);

                            if i>1
                                app.Speed(i,:) = sqrt((xdistcoord(i,:)-xdistcoord(i-1,:))^2+(ydistcoord(i,:)-ydistcoord(i-1,:))^2)*app.fps;
                            end
                            app.Eccentricity(i,:) = rp(v).Eccentricity;
                            Orientation(i,:) = rp(v).Orientation;
                            MajorAxisLength(i,:) = rp(v).MajorAxisLength;
                            MinorAxisLength(i,:) = rp(v).MinorAxisLength;
                            Area(i,:) = rp(v).Area;
                        end
                    catch
                        msgbox('No Rodent was detected')
                    end
                    drawnow
                end
                % Close dialog box
                close(d)
            else
                [~,~,ext] = fileparts(fullfile(app.folder,app.filename));
                files = dir(fullfile(app.folder,['*' ext]));
                app.DropDown.Items = {files.name};
                app.DropDown.Value = app.filename;
                pixel_width = app.Image_info.Width;
                pixel_height = app.Image_info.Height;

                app.Trace_Window.UIAxes.XLim = [0 app.Image_info.Width];
                app.Trace_Window.UIAxes.YLim = [0 app.Image_info.Height];

                if isempty(app.real_width)
                    real_dim = inputdlg({'Enter image/frame width:','Enter image/frame name:','Units:'},'Frame Dimensions',[1 45],{'30','30','cm'});
                    app.real_width = str2double(real_dim{1});
                    app.real_height = str2double(real_dim{2});
                    app.real_units = real_dim{3};
                end

                app.fps = app.Image_info.FrameRate;
                app.TimeSlider.Limits(2)=app.Image_info.Duration;

                app.ProgressText.Text = 'Analyzing...';
                app.ProgressText.Visible = "on";

                app.FileInfoText.Text = {['FPS: ' num2str(app.fps)];['width: ' num2str(app.real_width) ' ' app.real_units];['height: ' num2str(app.real_height) ' ' app.real_units]};
                app.FileInfoText.Visible = "on";

                d = uiprogressdlg(app.RodentTrackerUIFigure,'Title','Analyzing Data Please Wait',...
                    'Message','Analyzing...');

                for i = 1:app.Image_info.NumFrames-1%i = floor(app.TimeSlider.Value*app.fps+1);

%                     app.ProgressText.Text = ['Analyzing... ' num2str(100*(i/(size(app.Image_info,1)-1))) '%'];

                    d.Value = (i/(app.Image_info.NumFrames-1));
                    d.Message = ['Analyzing... ' num2str(round(100*(i/(app.Image_info.NumFrames-1)),2),"%.2f") '%'];



                    if size(size(app.Background_Image),2)==3
                        % Convert to Binary Image

                        if isfloat(app.Image)

                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < app.BinaryThresholdSlider.Value);
                            else
                                bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) > app.BinaryThresholdSlider.Value;
                            end
                        else
                            if isa(app.Background_Image,'uint8')
                                if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                    bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < 255*app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < 255*app.BinaryThresholdSlider.Value);
                                else
                                    bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) >= 255*app.BinaryThresholdSlider.Value;
                                end

                            end
                            if isa(app.Background_Image,'uint16')
                                if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                    bw_display_image = (rgb2gray(app.Image(:,:,:,i)) < 65535*app.BinaryThresholdSlider.Value)-(rgb2gray(app.Background_Image) < 65535*app.BinaryThresholdSlider.Value);
                                else
                                    bw_display_image = rgb2gray(app.Image(:,:,:,i)-app.Background_Image) >= 65535*app.BinaryThresholdSlider.Value;
                                end
                            end
                        end
                    else
                        % GRAYSCALE TIFF

                        % Convert to Binary Image

                        if isfloat(app.Image)

                            if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                bw_display_image = (app.Image(:,:,i)<app.BinaryThresholdSlider.Value)-(app.Background_Image<app.BinaryThresholdSlider.Value);
                            else
                                bw_display_image = app.Image(:,:,i)-app.Background_Image > app.BinaryThresholdSlider.Value;
                            end
                        else
                            if isa(app.Background_Image,'uint8')
                                if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                    bw_display_image = (app.Image(:,:,i)<= 255*app.BinaryThresholdSlider.Value)-(app.Background_Image<= 255*app.BinaryThresholdSlider.Value);
                                else
                                    bw_display_image = app.Image(:,:,i)-app.Background_Image >= 255*app.BinaryThresholdSlider.Value;
                                end
    
                            end
                            if isa(app.Background_Image,'uint16')
                                if string(app.BackgroundButtonGroup.SelectedObject.Text) == "Light"
                                    bw_display_image = (app.Image(:,:,i)<= 65535*app.BinaryThresholdSlider.Value)-(app.Background_Image<= 65535*app.BinaryThresholdSlider.Value);
                                else
                                    bw_display_image = app.Image(:,:,i)-app.Background_Image >= 65535*app.BinaryThresholdSlider.Value;
                                end
                            end
                        end
                    end

                    % Remove tail
                    se = strel('disk',round(app.StructuralElementSizeSlider.Value));
                    bw_display_image_NT = imopen(bw_display_image,se);

                    rp = regionprops(bw_display_image,'Orientation', 'MajorAxisLength', ...
                        'MinorAxisLength', 'Eccentricity', 'Centroid','Area');

                    ellipsenum = length(rp); %Number of ellipses detected in frame

                    if ellipsenum < 2
                        input = 1;
                    elseif ellipsenum > 1
                        for ii = 1:1:length(rp)
                            [sizesofellipses(ii)] = rp(ii).MajorAxisLength*rp(ii).MinorAxisLength; %Finds the rectangular area of ellipse
                        end
                        [~, input] = max(sizesofellipses);%Determine input that creates largest ellipse based on rectangular area
                        clear 'sizesofellipses'; %Clears array of rectangular areas b/c next iteriation may have less ellipes, so this ensures it doesn't pick a value from a previous iteriation.
                    end

                    %Display plot of largest ellipse (Used code from Steve Eddins' blog article,"Visualizing regionprops ellipse measurements" % _Steve Eddins_% _Copyright 2010 The MathWorks, Inc)

                    phi = linspace(0,2*pi,50);
                    cosphi = cos(phi);
                    sinphi = sin(phi);

                    try
                    for v = input
                        xbar = rp(v).Centroid(1);
                        ybar = rp(v).Centroid(2);

                        a = rp(v).MajorAxisLength/2;
                        b = rp(v).MinorAxisLength/2;

                        theta = pi*rp(v).Orientation/180;
                        R = [cos(theta)   sin(theta)
                            -sin(theta)   cos(theta)];

                        xy = [a*cosphi; b*sinphi];
                        xy = R*xy;

                        x = xy(1,:) + xbar;
                        y = xy(2,:) + ybar;

                        xdistcoord(i,:) = xbar*(app.real_width/pixel_width);
                        ydistcoord(i,:) = ybar*(app.real_height/pixel_height);
                        

                        if i>1
                            app.Speed(i,:) = sqrt((xdistcoord(i,:)-xdistcoord(i-1,:))^2+(ydistcoord(i,:)-ydistcoord(i-1,:))^2)*app.fps;
                        end
                        app.Eccentricity(i,:) = rp(v).Eccentricity;
                        Orientation(i,:) = rp(v).Orientation;
                        MajorAxisLength(i,:) = rp(v).MajorAxisLength;
                        MinorAxisLength(i,:) = rp(v).MinorAxisLength;
                        Area(i,:) = rp(v).Area;

                    end
                    catch
                    end
                    drawnow
                end
                % Close dialog box
                close(d)
            end

            % Display Images
            
            % Raw Image
            if size(app.Image_info,1)>1
                imshow(app.Image(:,:,(size(app.Image_info,1)-1)),'Parent',app.Video_Window.RawAxes) % Tiff
            else
                imshow(app.Image(:,:,(app.Image_info.NumFrames-1)),'Parent',app.Video_Window.RawAxes) % Video
            end
            title(app.Video_Window.RawAxes,'Original Video')

            % Binary Image
            imshow(bw_display_image,'Parent',app.Video_Window.BinaryAxes)
            title(app.Video_Window.BinaryAxes,'Binary Video')

            % No Tail Image
            imshow(bw_display_image_NT,'Parent',app.Video_Window.NoTailAxes)
            title(app.Video_Window.NoTailAxes,'Remove Tail')

            % Display Ellipsed Roden
            imshow(bw_display_image,'Parent',app.Video_Window.EllipseAxes)
            hold(app.Video_Window.EllipseAxes,"on")
            if size(rp)>0
                plot(app.Video_Window.EllipseAxes,x,y,'color',app.EllipseColor,'LineWidth',2);
            end
            scatter(app.Video_Window.EllipseAxes,xbar,ybar,'.','MarkerFaceColor',app.CentroidColor,'MarkerEdgeColor',app.CentroidColor)
            title(app.Video_Window.EllipseAxes,'Draw Ellipse')
            hold(app.Video_Window.EllipseAxes,"off")

            % Display ROIs
        
            if ~isempty(app.ROI_Data)
                for ii = 1:size(app.ROI_Data,1)
                    if app.ROI_Data(ii,2)=="1"
                        Position = str2num(char([app.ROI_Data(ii,6:9)]'))';
                        if sum(isstrprop(app.ROI_Data(ii,5),'digit'))==0
                            app.ROI_Raw = drawrectangle(app.Video_Window.RawAxes,'Position',Position,'Color',app.ROI_Data(ii,5));
                            app.ROI_Binary = drawrectangle(app.Video_Window.BinaryAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                            app.ROI_NoTail = drawrectangle(app.Video_Window.NoTailAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                            app.ROI_Ellipse = drawrectangle(app.Video_Window.EllipseAxes,"Position",Position,'Color',app.ROI_Data(ii,5));
                        else
                            app.ROI_Raw = drawrectangle(app.Video_Window.RawAxes,'Position',Position,'Color',str2num(app.ROI_Data(ii,5)));
                            app.ROI_Binary = drawrectangle(app.Video_Window.BinaryAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                            app.ROI_NoTail = drawrectangle(app.Video_Window.NoTailAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                            app.ROI_Ellipse = drawrectangle(app.Video_Window.EllipseAxes,"Position",Position,'Color',str2num(app.ROI_Data(ii,5)));
                        end
                            app.ROI_Raw.InteractionsAllowed='none';
                            app.ROI_Binary.InteractionsAllowed='none';
                            app.ROI_NoTail.InteractionsAllowed='none';
                            app.ROI_Ellipse.InteractionsAllowed='none';
                            app.ROI.FaceSelectable=0;
                            app.ROI_Raw.FaceSelectable=0;
                            app.ROI_Binary.FaceSelectable=0;
                            app.ROI_NoTail.FaceSelectable=0;
                            app.ROI_Ellipse.FaceSelectable=0;
                    end
                end
            end

            % Display Trace for Video recording
            if app2.SaveTraceVideoCheckBox.Value == 1
                %     Tfig.Children(2).Visible = 'off';
                app.ProgressText.Text = 'Saving Trace Video...';
                v = VideoWriter(fullfile(app2.SaveDirectoryTrace.Value,[app2.TraceFilenameEditField.Value '.avi']),'Motion JPEG AVI');
                v.FrameRate = tr_fps;
                open(v)
                for i=1:length(xdistcoord)
                    scatter(app.Trace_Window.UIAxes,xdistcoord(i,1)*(pixel_width/real_width_TIFF),ydistcoord(i,1)*(pixel_height/real_height_TIFF),'.','MarkerFaceColor',app.TraceColor,'MarkerEdgeColor',app.TraceColor)
                    %         drawnow;
                    Trace_Image = getframe(app.Trace_Window.UIAxes);
                    Trace_Image = Trace_Image.cdata;
                    writeVideo(v,Trace_Image)
                end
                close(v)
                app.ProgressText.Text = 'Trace Video Saved';
                hold(app.Trace_Window.UIAxes,'off')
                imshow(app.Background_Image)
                hold(app.Trace_Window.UIAxes,"on")
                if size(app.Image_info,1)>1
                    scatter(app.Trace_Window.UIAxes,xdistcoord*(pixel_width/real_width_TIFF),ydistcoord*(pixel_height/real_height_TIFF),'.','MarkerFaceColor',app.TraceColor,'MarkerEdgeColor',app.TraceColor)
                else
                    scatter(app.Trace_Window.UIAxes,xdistcoord*(pixel_width/app.real_width),ydistcoord*(pixel_height/app.real_height),'.','MarkerFaceColor',app.TraceColor,'MarkerEdgeColor',app.TraceColor)
                end
                %     app.Trace_Window.Children(2).Visible = "on";
            else
                if size(app.Image_info,1)>1
                    scatter(app.Trace_Window.UIAxes,xdistcoord*(pixel_width/real_width_TIFF),ydistcoord*(pixel_height/real_height_TIFF),'.','MarkerFaceColor',app.TraceColor,'MarkerEdgeColor',app.TraceColor)
                else
                    scatter(app.Trace_Window.UIAxes,xdistcoord*(pixel_width/app.real_width),ydistcoord*(pixel_height/app.real_height),'.','MarkerFaceColor',app.TraceColor,'MarkerEdgeColor',app.TraceColor)
                end
            end

            % Display Ellipsed Rodent for Video Recording
            if app2.SaveTrackerVideoCheckBox.Value == 1
                      
               ax1 = uiaxes;
               ax1.Parent.Position(3) = size(app.Background_Image,1);
               ax1.Parent.Position(4) = size(app.Background_Image,2);
               ax1.Parent.Units = 'normalized';
               ax1.Parent.Position(1) = .3;
               ax1.Parent.Position(2) = .2;
               ax1.Parent.Icon = "RodentTrackerIcon.png";
               ax1.Parent.Name = "Rodent Tracker: recording";
               imshow(app.Background_Image,'Parent',ax1);
               ax1.Units = 'normalized';
               ax1.Position = [0 0 1 1];
               xlim(ax1,[0 size(app.Background_Image,1)])
               ylim(ax1,[0 size(app.Background_Image,2)])
               ax1.Parent.Resize ='off';
               
               app.ProgressText.Text = 'Saving Tracker Video...';
                pv = VideoWriter(fullfile(app2.SaveDirectoryTracker.Value,[app2.TrackerFilenameEditField.Value '.avi']),'Motion JPEG AVI');
                pv.FrameRate = ap_fps;
                open(pv)

               %Display plot of largest ellipse (Used code from Steve Eddins' blog article,"Visualizing regionprops ellipse measurements" % _Steve Eddins_% _Copyright 2010 The MathWorks, Inc)
               for i = 1:length(xdistcoord)

                     if size(size(app.Background_Image),2)==3
                        imshow(app.Image(:,:,:,i),'Parent',ax1);
                     else
                        imshow(app.Image(:,:,i),'Parent',ax1);
                     end

                     try
                         xbar = xdistcoord(i,:)/(real_width_TIFF/pixel_width);
                         ybar = ydistcoord(i,:)/(real_height_TIFF/pixel_height);

                         a = MajorAxisLength(i,:)/2;
                         b = MinorAxisLength(i,:)/2;

                         xy = [a*cosphi; b*sinphi];


                         theta = pi*Orientation(i,:)/180;
                         R = [cos(theta)   sin(theta)
                             -sin(theta)   cos(theta)];

                         xy = R*xy;

                         x = xy(1,:) + xbar;
                         y = xy(2,:) + ybar;

                         % Display Ellipsed Rodent
                         hold(ax1,"on")
                         plot(ax1,x,y,'color',app.EllipseColor,'LineWidth',2);
                     catch
                         disp(['No rodent detected on frame ' num2str(i)])
                     end
                     hold(ax1,"off")
                     Preview_Image = getframe(ax1);
                     Preview_Image = Preview_Image.cdata;
                     try
                         writeVideo(pv,Preview_Image)
                     catch
                         disp(['Frame' num2str(i) ' is not the correct dimensions'])
                     end
                end
%                     drawnow
          
               close(pv)
               app.ProgressText.Text = 'Preview Video Saved';
            end

            if ~isempty(app.ROI_Data)
            % ROI calculations

            x_trace=app.Trace_Window.UIAxes.Children(1).XData;
            y_trace=app.Trace_Window.UIAxes.Children(1).YData;
            % figure
            % scatter(x_trace,y_trace)
            % hold on
            
            for ii = 1:size(app.ROI_Data,1)
                x = [double(app.ROI_Data(ii,6)),double(app.ROI_Data(ii,6))+double(app.ROI_Data(ii,8))];
                y = [double(app.ROI_Data(ii,7)),double(app.ROI_Data(ii,7))+double(app.ROI_Data(ii,9))];
                inside_points(:,:,ii) = inpolygon(x_trace,y_trace,[x(1) x(1) x(2) x(2) x(1)],[y y(2) y(1) y(1)]);
%                 scatter(app.Trace_Window.UIAxes,x_trace(inside_points(:,:,ii)),y_trace(inside_points(:,:,ii)),"MarkerFaceColor",app.ROI_Data(ii,5))
            
           
            
            ROI_percentage(:,ii) = 100*(sum(inside_points(:,:,ii))/length(inside_points(:,:,ii)));

            hold(app.Trace_Window.UIAxes,"on");
            scatter(app.Trace_Window.UIAxes,x_trace(inside_points(:,:,ii)),y_trace(inside_points(:,:,ii)),"MarkerFaceColor",app.ROI_Data(ii,5),"MarkerEdgeColor",app.ROI_Data(ii,5));%,"LineWidth",2
            
            %Entries
            
            Number_Entries(:,ii) = length(strfind(inside_points(:,:,ii),[0 1]));
            % scatter(x_trace(strfind(inside_points(:,:,ii),[0 1])),y_trace(strfind(inside_points(:,:,ii),[0 1])),'.')
            Number_Exits(:,ii) = length(strfind(inside_points(:,:,ii),[1 0]));
            % scatter(x_trace(strfind(inside_points(:,:,ii),[1 0])),y_trace(strfind(inside_points(:,:,ii),[1 0])),'.')
            
            
            
            end
            %Time Spent
            TimeSpent_ROI = (length(inside_points(:,:,ii))*ROI_percentage/100)/app.fps;
            
            end
            % Spreadsheet

            app.t=table;
            app.t.Eccentricity = app.Eccentricity;
            app.t.Speed = app.Speed;
            app.t.xcoord = xdistcoord;
            app.t.ycoord = ydistcoord;
            app.t.Orientation = Orientation;
            app.t.Area = Area;
            app.t.MajorAxisLength = MajorAxisLength;
            app.t.MinorAxisLength = MinorAxisLength;
            if ~isempty(app.ROI_Data)
            app.t2=table;
            app.t2.ROI = app.ROI_Data(:,4);
            app.t2.Color = app.ROI_Data(:,5);
            app.t2.TimeSpent_ROI = TimeSpent_ROI';
            app.t2.PercentageSpent_ROI = ROI_percentage';
            app.t2.Number_Entries = Number_Entries';
            app.t2.Number_Exits = Number_Exits';

            app.ROI_Results_Window.RodentTrackerROIResultsUIFigure.Visible = 'on';
            app.ROI_Results_Window.UITable.Data = app.t2;
            app.ROI_Results_Window.UITable.ColumnName = app.t2.Properties.VariableNames;
            app.ROI_Results_Window.UITable.Units = "normalized";
            app.ROI_Results_Window.UITable.Position = [0 0 1 1];
            app.ROI_Results_Window.UITable.Units = 'pixels';
            
            for ii = 1:size(app.ROI_Data,1)
                if sum(isstrprop(app.ROI_Results_Window.UITable.Data{ii,2},'digit'))==0
                    s = uistyle('BackgroundColor',app.ROI_Results_Window.UITable.Data{ii,2});
                    addStyle(app.ROI_Results_Window.UITable,s,"cell",[ii,2]);
                else
                    s = uistyle('BackgroundColor',str2num(app.ROI_Results_Window.UITable.Data{ii,2}));
                    addStyle(app.ROI_Results_Window.UITable,s,"cell",[ii,2]);
                end
            end
            app.ROIresultsMenu.Enable = "on";
            app.ROIresultsMenu.Checked = "on";
            end
     
            app.Spreadsheet_Window.RodentTrackerSpreadsheetUIFigure.Visible = 'on';
            app.Spreadsheet_Window.UITable.ColumnName = app.t.Properties.VariableNames;
            app.Spreadsheet_Window.UITable.Units = "normalized";
            app.Spreadsheet_Window.UITable.Position = [0 0 1 1];
            app.Spreadsheet_Window.UITable.Units = 'pixels';
            app.Spreadsheet_Window.UITable.Data = app.t;

            app.ProgressText.Text = 'Analysis Complete';

            app.ValidationMenu.Enable = "on";
            app.ResultsMenu.Enable = "on";
            app.MainSpreadsheetMenu.Enable = "on";
            app.MainSpreadsheetMenu.Checked = "on";
                        

            figure(app.Video_Window.RodentTrackerAnalysisPreviewUIFigure)
            figure(app.Trace_Window.RodentTrackerTraceUIFigure)
            figure(app.Spreadsheet_Window.RodentTrackerSpreadsheetUIFigure)
            figure(app.RodentTrackerUIFigure)
        end

        % Menu selected function: AnalyzeMenu
        function AnalyzeMenuSelected(app, event)
            AnalyzeButtonPushed(app)
        end

        % Button pushed function: LeftArrowSEThresholdSlider
        function LeftArrowSEThresholdSliderButtonPushed(app, event)
            if round(app.StructuralElementSizeSlider.Value) > 0
            app.StructuralElementSizeSlider.Value = round(app.StructuralElementSizeSlider.Value)-1;
            end
            StructuralElementSizeSliderValueChanged(app)
        end

        % Button pushed function: RightArrowSEThresholdSlider
        function RightArrowSEThresholdSliderButtonPushed(app, event)
            app.StructuralElementSizeSlider.Value = round(app.StructuralElementSizeSlider.Value)+1;
            StructuralElementSizeSliderValueChanged(app)
        end

        % Button pushed function: LeftArrowBinaryThresholdSlider
        function LeftArrowBinaryThresholdSliderButtonPushed(app, event)
            if app.BinaryThresholdSlider.Value > 0
                app.BinaryThresholdSlider.Value = round(app.BinaryThresholdSlider.Value,2)-0.01; 
            end
            BinaryThresholdSliderValueChanged(app)
        end

        % Button pushed function: RightArrowBinaryThresholdSlider
        function RightArrowBinaryThresholdSliderButtonPushed(app, event)
            if app.BinaryThresholdSlider.Value < 1
                app.BinaryThresholdSlider.Value = round(app.BinaryThresholdSlider.Value,2)+0.01;
            end
            BinaryThresholdSliderValueChanged(app)
        end

        % Button pushed function: LeftArrowTimeSlider
        function LeftArrowTimeSliderButtonPushed(app, event)
            if app.TimeSlider.Value >= 1/app.fps
               app.TimeSlider.Value = app.TimeSlider.Value - 1/app.fps;
            end
            TimeSliderValueChanged(app)
        end

        % Button pushed function: RightArrowTimeSlider
        function RightArrowTimeSliderButtonPushed(app, event)
            if app.TimeSlider.Value <= app.TimeSlider.Limits(2) - 1/app.fps
                app.TimeSlider.Value = app.TimeSlider.Value + 1/app.fps;
            end
            TimeSliderValueChanged(app)
        end

        % Value changed function: BinaryThresholdEditField
        function BinaryThresholdEditFieldValueChanged(app, event)
            app.BinaryThresholdSlider.Value = app.BinaryThresholdEditField.Value;
            BinaryThresholdSliderValueChanged(app)
        end

        % Value changed function: SEThresholdEditField
        function SEThresholdEditFieldValueChanged(app, event)
            app.SEThresholdEditField.Value = round(app.SEThresholdEditField.Value);
            app.StructuralElementSizeSlider.Value = app.SEThresholdEditField.Value;
            StructuralElementSizeSliderValueChanged(app)
        end

        % Value changed function: TimesEditField
        function TimesEditFieldValueChanged(app, event)
            app.TimeSlider.Value = app.TimesEditField.Value;
            TimeSliderValueChanged(app)
        end

        % Menu selected function: TraceColorMenu
        function TraceColorMenuSelected(app, event)
            app.TraceColor = uisetcolor;
            
            if ~isempty(app.Trace_Window.UIAxes.Children)
            app.Trace_Window.UIAxes.Children(1).MarkerFaceColor = app.TraceColor;
            app.Trace_Window.UIAxes.Children(1).MarkerEdgeColor = app.TraceColor;
            end

            figure(app.Video_Window.RodentTrackerAnalysisPreviewUIFigure)
            figure(app.Trace_Window.RodentTrackerTraceUIFigure)
            figure(app.Spreadsheet_Window.RodentTrackerSpreadsheetUIFigure)
            figure(app.RodentTrackerUIFigure)
        end

        % Menu selected function: EllipseColorMenu
        function EllipseColorMenuSelected(app, event)
            app.EllipseColor = uisetcolor;

            app.Video_Window.EllipseAxes.Children(4).Color = app.EllipseColor;
            
            figure(app.Video_Window.RodentTrackerAnalysisPreviewUIFigure)
            figure(app.Trace_Window.RodentTrackerTraceUIFigure)
            figure(app.Spreadsheet_Window.RodentTrackerSpreadsheetUIFigure)
            figure(app.RodentTrackerUIFigure)
        end

        % Menu selected function: CentroidColorMenu
        function CentroidColorMenuSelected(app, event)
            app.CentroidColor = uisetcolor;
            
            app.Video_Window.EllipseAxes.Children(3).MarkerFaceColor = app.CentroidColor;
            app.Video_Window.EllipseAxes.Children(3).MarkerEdgeColor = app.CentroidColor;

            figure(app.Video_Window.RodentTrackerAnalysisPreviewUIFigure)
            figure(app.Trace_Window.RodentTrackerTraceUIFigure)
            figure(app.Spreadsheet_Window.RodentTrackerSpreadsheetUIFigure)
            figure(app.RodentTrackerUIFigure)
        end

        % Button pushed function: ResetButton
        function ResetButtonPushed(app, event)
            app.TimeSlider.Value = 0;
        end

        % Selection changed function: BackgroundButtonGroup
        function BackgroundButtonGroupSelectionChanged(app, event)
            TimeSliderValueChanged(app)
        end

        % Menu selected function: TailColorMenu
        function TailColorMenuSelected(app, event)
            app.TailpointColor = uisetcolor;
            
            app.Video_Window.EllipseAxes.Children(2).MarkerFaceColor = app.TailpointColor;
            app.Video_Window.EllipseAxes.Children(2).MarkerEdgeColor = app.TailpointColor;

            figure(app.Video_Window.RodentTrackerAnalysisPreviewUIFigure)
            figure(app.Trace_Window.RodentTrackerTraceUIFigure)
            figure(app.Spreadsheet_Window.RodentTrackerSpreadsheetUIFigure)
            figure(app.RodentTrackerUIFigure)
        end

        % Menu selected function: HeadColorMenu
        function HeadColorMenuSelected(app, event)
            app.HeadpointColor = uisetcolor;
            
            app.Video_Window.EllipseAxes.Children(1).MarkerFaceColor = app.HeadpointColor;
            app.Video_Window.EllipseAxes.Children(1).MarkerEdgeColor = app.HeadpointColor;

            figure(app.Video_Window.RodentTrackerAnalysisPreviewUIFigure)
            figure(app.Trace_Window.RodentTrackerTraceUIFigure)
            figure(app.Spreadsheet_Window.RodentTrackerSpreadsheetUIFigure)
            figure(app.RodentTrackerUIFigure)
        end

        % Menu selected function: VideoBackgroundLastframeMenu
        function VideoBackgroundLastframeMenuSelected(app, event)
            imshow(app.Image(:,:,end),"Parent",app.Background_Window.UIAxes)
            app.Background_Window.BackgroundUIFigure.Visible ="on";

            app.Background_Window.UIAxes.XLim = [0 size(app.Background_Image,1)];
            app.Background_Window.UIAxes.YLim = [0 size(app.Background_Image,2)];

        end

        % Menu selected function: ClearTraceMenu
        function ClearTraceMenuSelected(app, event)
            ClearTraceButtonPushed(app)
        end

        % Menu selected function: SAPMenu
        function SAPMenuSelected(app, event)
            if app.SAP_Window.RodentTrackerSAPDetectionUIFigure.Visible == "on" 
                app.SAP_Window.RodentTrackerSAPDetectionUIFigure.Visible = "off";
                app.SAPMenu.Checked = "off";
                app.Spreadsheet_Window.SAPMenu.Checked = "off";
            else
                app.SAP_Window.RodentTrackerSAPDetectionUIFigure.Visible = "on";
                app.SAPMenu.Checked = "on";
                app.Spreadsheet_Window.SAPMenu.Checked = "on";
                figure(app.SAP_Window.RodentTrackerSAPDetectionUIFigure)
            end
        end

        % Menu selected function: VideoWindowMenu
        function VideoWindowMenuSelected(app, event)
            if app.Video_Window.RodentTrackerAnalysisPreviewUIFigure.Visible == "on"
                app.Video_Window.RodentTrackerAnalysisPreviewUIFigure.Visible = "off";
                app.VideoWindowMenu.Checked = "off";
            else
                app.Video_Window.RodentTrackerAnalysisPreviewUIFigure.Visible = "on";
                figure(app.Video_Window.RodentTrackerAnalysisPreviewUIFigure)
                app.VideoWindowMenu.Checked = "on";
            end
        end

        % Menu selected function: TraceWindowMenu
        function TraceWindowMenuSelected(app, event)
            if  app.Trace_Window.RodentTrackerTraceUIFigure.Visible == "on"
                app.Trace_Window.RodentTrackerTraceUIFigure.Visible = "off";
                app.TraceWindowMenu.Checked = "off";
            else
                app.Trace_Window.RodentTrackerTraceUIFigure.Visible = "on";
                figure(app.Trace_Window.RodentTrackerTraceUIFigure)
                app.TraceWindowMenu.Checked = "on";
            end
        end

        % Menu selected function: MainSpreadsheetMenu
        function MainSpreadsheetMenuSelected(app, event)
            if app.Spreadsheet_Window.RodentTrackerSpreadsheetUIFigure.Visible == "on"
                app.Spreadsheet_Window.RodentTrackerSpreadsheetUIFigure.Visible = "off";
                app.MainSpreadsheetMenu.Checked = "off";
            else
                app.Spreadsheet_Window.RodentTrackerSpreadsheetUIFigure.Visible = "on";
                figure(app.Spreadsheet_Window.RodentTrackerSpreadsheetUIFigure)
                app.MainSpreadsheetMenu.Checked = "on";
            end
        end

        % Menu selected function: ROIresultsMenu
        function ROIresultsMenuSelected(app, event)
            if app.ROI_Results_Window.RodentTrackerROIResultsUIFigure.Visible == "on"
                app.ROI_Results_Window.RodentTrackerROIResultsUIFigure.Visible = "off";
                app.ROIresultsMenu.Checked = "off";
            else
                app.ROI_Results_Window.RodentTrackerROIResultsUIFigure.Visible = "on";
                figure(app.ROI_Results_Window.RodentTrackerROIResultsUIFigure)
                app.ROIresultsMenu.Checked = "on";
            end
        end

        % Menu selected function: ROISelectorMenu
        function ROISelectorMenuSelected(app, event)
            if app.Video_Window.ROI_Window.RodentTrackerRegionofInterestSelectionUIFigure.Visible == "on"
                app.Video_Window.ROI_Window.RodentTrackerRegionofInterestSelectionUIFigure.Visible = "off";
                app.ROISelectorMenu.Checked = "off";
                app.Video_Window.ROISelectorMenu.Checked = "off";
            else
                app.Video_Window.ROI_Window.RodentTrackerRegionofInterestSelectionUIFigure.Visible = "on";
                figure(app.Video_Window.ROI_Window.RodentTrackerRegionofInterestSelectionUIFigure)
                app.ROISelectorMenu.Checked = "on";
                app.Video_Window.ROISelectorMenu.Checked = "on";
                if isempty(app.Video_Window.ROI_Window.UIAxes.Children)
                    imshow(app.Video_Window.RawAxes.Children(end).CData,'Parent',app.Video_Window.ROI_Window.UIAxes)
                    app.Video_Window.ROI_Window.UIAxes.XLim = [0 size(app.Video_Window.RawAxes.Children(end).CData,1)];
                    app.Video_Window.ROI_Window.UIAxes.YLim = [0 size(app.Video_Window.RawAxes.Children(end).CData,2)];
                end
            end
        end
    end

    % App creation
    methods (Access = public)

        % Construct app
        function app = RodentTracker(varargin)
            app = app@matlab.apps.App(varargin{:});

            if nargout == 0
                clear app
            end
        end
    end
end
