classdef RodentTracker_ROI_Window < matlab.apps.App

    % Used to locate and load the app's XML configuration file
    properties (Access = public, Constant)
        AppConfigFilename = './RodentTracker_ROI_Window.xml'; % File path to the app configuration file containing component layout and settings
    end

    % Properties that correspond to app components
    properties (Access = public)
        RodentTrackerRegionofInterestSelectionUIFigure  matlab.ui.Figure
        FileMenu                        matlab.ui.container.Menu
        CreateNewROIMenu                matlab.ui.container.Menu
        DeleteSelectedROIsMenu          matlab.ui.container.Menu
        SetupMenu                       matlab.ui.container.Menu
        OpenFieldMenu                   matlab.ui.container.Menu
        ElevatedPlusMazeMenu            matlab.ui.container.Menu
        EditMenu                        matlab.ui.container.Menu
        GridLayout                      matlab.ui.container.GridLayout
        SpecificSetupPanel              matlab.ui.container.Panel
        OFButton                        matlab.ui.control.Button
        EPMButton                       matlab.ui.control.Button
        CombineButton                   matlab.ui.control.Button
        GridPanel                       matlab.ui.container.Panel
        ColormapDropDown                matlab.ui.control.DropDown
        ColormapDropDownLabel           matlab.ui.control.Label
        GenerateROIsButton              matlab.ui.control.Button
        heightEditField                 matlab.ui.control.NumericEditField
        heightEditFieldLabel            matlab.ui.control.Label
        widthEditField                  matlab.ui.control.NumericEditField
        widthEditFieldLabel             matlab.ui.control.Label
        UITable                         matlab.ui.control.Table
        SelectROIButton                 matlab.ui.control.Button
        UIAxes                          matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        Callingapp
        ROIcount=0;
    end

    % Callbacks that handle component events
    methods

        % Code that executes after component creation
        function startupFcn(app, Mainapp)
            %Position
            screen = get(0,'screensize');
            xres = screen(3)-screen(1);
            yres = screen(4)-screen(2);

            app.RodentTrackerRegionofInterestSelectionUIFigure.Visible = "off";
            
            %Position
            app.RodentTrackerRegionofInterestSelectionUIFigure.Units = 'normalized';
            app.RodentTrackerRegionofInterestSelectionUIFigure.Position = [0.3 0.1 0.6*(yres/xres) 0.8];%
            app.RodentTrackerRegionofInterestSelectionUIFigure.Units = 'pixels';

            
            app.ROIcount=0;

            app.Callingapp = Mainapp;
%             imshow(app.Callingapp.RawAxes.Children(end).CData,'Parent',app.UIAxes)
%             app.UIAxes.XLim = [0 size(app.Callingapp.RawAxes.Children(end).CData,1)];
%             app.UIAxes.YLim = [0 size(app.Callingapp.RawAxes.Children(end).CData,2)];
        end

        % Button pushed function: SelectROIButton
        function SelectROIButtonPushed(app, event)
            if app.SelectROIButton.Text == "Select ROI"
                app.SelectROIButton.Text = "Set ROI";
                app.Callingapp.Callingapp.ROI = drawrectangle(app.UIAxes,"Color",'red');

                addlistener(app.Callingapp.Callingapp.ROI,'MovingROI',@ROIevents);
                addlistener(app.Callingapp.Callingapp.ROI,'ROIMoved',@ROIevents);
% 
%                 function ROIevents(src,evt)
%                     evname = evt.EventName;
%                     switch(evname)
%                         case{'MovingROI'}
%                             disp(['ROI moving previous position: ' mat2str(evt.PreviousPosition)]);
%                             disp(['ROI moving current position: ' mat2str(evt.CurrentPosition)]);
%                         case{'ROIMoved'}
%                             disp(['ROI moved previous position: ' mat2str(evt.PreviousPosition)]);
%                             disp(['ROI moved current position: ' mat2str(evt.CurrentPosition)]);
%                     end
%                 end
                app.UITable.ColumnFormat= {'logical','logical','logical', 'char', {'red', 'green', 'blue', 'magenta','cyan','yellow','other'}, 'numeric', 'numeric', 'numeric'};

                app.ROIcount = app.ROIcount+1;
                if isempty(app.UITable.Data)
                app.UITable.Data = " ";
                end
                app.Callingapp.Callingapp.ROI.Tag = num2str(app.ROIcount);
                app.UITable.Data(app.ROIcount,2) = 1;
                app.UITable.Data(app.ROIcount,3) = 0;
                app.UITable.Data(app.ROIcount,4) = "New ROI";
                app.UITable.Data(app.ROIcount,5) = "red";
                s = uistyle('BackgroundColor',[1 0 0]);
                addStyle(app.UITable,s,"cell",[app.ROIcount,5]);
                app.UITable.Data(app.ROIcount,6:9) = app.Callingapp.Callingapp.ROI.Position;

            else
                app.SelectROIButton.Text = "Select ROI";
                app.Callingapp.Callingapp.ROI.InteractionsAllowed='none';
                app.Callingapp.Callingapp.ROI.FaceSelectable=0;
                app.Callingapp.Callingapp.ROI_Raw = drawrectangle(app.Callingapp.RawAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                app.Callingapp.Callingapp.ROI_Binary = drawrectangle(app.Callingapp.BinaryAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                app.Callingapp.Callingapp.ROI_NoTail = drawrectangle(app.Callingapp.NoTailAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                app.Callingapp.Callingapp.ROI_Ellipse = drawrectangle(app.Callingapp.EllipseAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                app.Callingapp.Callingapp.ROI_Raw.InteractionsAllowed='none';
                app.Callingapp.Callingapp.ROI_Binary.InteractionsAllowed='none';
                app.Callingapp.Callingapp.ROI_NoTail.InteractionsAllowed='none';
                app.Callingapp.Callingapp.ROI_Ellipse.InteractionsAllowed='none';
                app.Callingapp.Callingapp.ROI_Raw.FaceSelectable=0;
                app.Callingapp.Callingapp.ROI_Binary.FaceSelectable=0;
                app.Callingapp.Callingapp.ROI_NoTail.FaceSelectable=0;
                app.Callingapp.Callingapp.ROI_Ellipse.FaceSelectable=0;

                app.Callingapp.Callingapp.ROI_Data = app.UITable.Data;
% 
%                 app.Callingapp.Callingapp.ROI_Position = app.Callingapp.Callingapp.ROI.Position';
%                 app.Callingapp.Callingapp.ROI_Raw_Position = app.Callingapp.Callingapp.ROI.Position';
%                 app.Callingapp.Callingapp.ROI_Binary_Position = app.Callingapp.Callingapp.ROI.Position';
%                 app.Callingapp.Callingapp.ROI_NoTail_Position = app.Callingapp.Callingapp.ROI.Position';
%                 app.Callingapp.Callingapp.ROI_Ellipse_Position = app.Callingapp.Callingapp.ROI.Position';
% 
%                 app.Callingapp.Callingapp.ROI_coord=app.Callingapp.Callingapp.ROI.Position;
            end
        end

        % Display data changed function: UITable
        function UITableDisplayDataChanged(app, event)
%             newDisplayData = app.UITable.DisplayData;
                indices = event.DisplaySelection;
        
                if app.SelectROIButton.Text == "Set ROI"
                    app.SelectROIButton.Text = "Select ROI";
                    app.Callingapp.Callingapp.ROI.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_Raw = drawrectangle(app.Callingapp.RawAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                    app.Callingapp.Callingapp.ROI_Binary = drawrectangle(app.Callingapp.BinaryAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                    app.Callingapp.Callingapp.ROI_NoTail = drawrectangle(app.Callingapp.NoTailAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                    app.Callingapp.Callingapp.ROI_Ellipse = drawrectangle(app.Callingapp.EllipseAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                    app.Callingapp.Callingapp.ROI_Raw.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_Binary.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_NoTail.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_Ellipse.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_Raw.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_Binary.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_NoTail.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_Ellipse.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_Data = app.UITable.Data;
                end


                    % Selection
                    if event.InteractionColumn  == 1 || indices(2) == 1
                        if sum(str2double(event.Source.Data(:,1)),"omitnan")>1
                            app.CombineButton.Enable = "on";
                        else
                            app.CombineButton.Enable = "off";
                        end
                    end

                    % Visibility
                    if event.InteractionColumn  == 2
                        a = str2num(char(event.Source.Data(:,2)))'.*(1:size(app.UITable.Data,1));
                        a = a(a~=0);
                        for ii = a
                            app.Callingapp.Callingapp.ROI.Parent.Children(size(app.UITable.Data,1)-ii+1).Visible = "on";
                        end
                        a = abs(str2num(char(event.Source.Data(:,2)))'-1).*(1:size(app.UITable.Data,1));
                        a = a(a~=0);
                        for ii = a
                            app.Callingapp.Callingapp.ROI.Parent.Children(size(app.UITable.Data,1)-ii+1).Visible = "off";
                        end
                    end
                    
                        % Editable
                        if event.InteractionColumn == 3
                            a = str2num(char(event.Source.Data(:,3)))'.*(1:size(app.UITable.Data,1));
                            a = a(a~=0);
                            for ii = a
                                app.Callingapp.Callingapp.ROI.Parent.Children(size(app.UITable.Data,1)-ii+1).InteractionsAllowed = "all";

                                addlistener(app.Callingapp.Callingapp.ROI,'MovingROI',@ROIevents);
                                addlistener(app.Callingapp.Callingapp.ROI,'ROIMoved',@ROIevents);
                            end
                            a = abs(str2num(char(event.Source.Data(:,3)))'-1).*(1:size(app.UITable.Data,1));
                            a = a(a~=0);
                        for ii = a
                            app.Callingapp.Callingapp.ROI.Parent.Children(size(app.UITable.Data,1)-ii+1).InteractionsAllowed  = "none";
                        end
                        end

                        if indices>0


                    try
                        if indices(2) == 5
                            switch event.Source.Data(indices(1),indices(2))
                                case "red"
                                    s = uistyle('BackgroundColor',[1 0 0]);
                                    app.UIAxes.Children(end-indices(1)).Color = [1 0 0];
                                    app.Callingapp.Callingapp.ROI_Raw.Parent.Children(end-indices(1)).Color = [1 0 0];
                                    app.Callingapp.Callingapp.ROI_Binary.Parent.Children(end-indices(1)).Color = [1 0 0];
                                    app.Callingapp.Callingapp.ROI_NoTail.Parent.Children(end-indices(1)).Color = [1 0 0];
                                    app.Callingapp.Callingapp.ROI_Ellipse.Parent.Children(end-indices(1)-4).Color = [1 0 0];
                                case "green"
                                    s = uistyle('BackgroundColor',[0 1 0]);
                                    app.UIAxes.Children(end-indices(1)).Color = [0 1 0];
                                    app.Callingapp.Callingapp.ROI_Raw.Parent.Children(end-indices(1)).Color = [0 1 0];
                                    app.Callingapp.Callingapp.ROI_Binary.Parent.Children(end-indices(1)).Color = [0 1 0];
                                    app.Callingapp.Callingapp.ROI_NoTail.Parent.Children(end-indices(1)).Color = [0 1 0];
                                    app.Callingapp.Callingapp.ROI_Ellipse.Parent.Children(end-indices(1)-4).Color = [0 1 0];
                                case "blue"
                                    s = uistyle('BackgroundColor',[0 0 1]);
                                    app.UIAxes.Children(end-indices(1)).Color = [0 0 1];
                                    app.Callingapp.Callingapp.ROI_Raw.Parent.Children(end-indices(1)).Color = [0 0 1];
                                    app.Callingapp.Callingapp.ROI_Binary.Parent.Children(end-indices(1)).Color = [0 0 1];
                                    app.Callingapp.Callingapp.ROI_NoTail.Parent.Children(end-indices(1)).Color = [0 0 1];
                                    app.Callingapp.Callingapp.ROI_Ellipse.Parent.Children(end-indices(1)-4).Color = [0 0 1];
                                case "magenta"
                                    s = uistyle('BackgroundColor',[1 0 1]);
                                    app.UIAxes.Children(end-indices(1)).Color = [1 0 1];
                                    app.Callingapp.Callingapp.ROI_Raw.Parent.Children(end-indices(1)).Color = [1 0 1];
                                    app.Callingapp.Callingapp.ROI_Binary.Parent.Children(end-indices(1)).Color = [1 0 1];
                                    app.Callingapp.Callingapp.ROI_NoTail.Parent.Children(end-indices(1)).Color = [1 0 1];
                                    app.Callingapp.Callingapp.ROI_Ellipse.Parent.Children(end-indices(1)-4).Color = [1 0 1];
                                case "cyan"
                                    s = uistyle('BackgroundColor',[0 1 1]);
                                    app.UIAxes.Children(end-indices(1)).Color = [0 1 1];
                                    app.Callingapp.Callingapp.ROI_Raw.Parent.Children(end-indices(1)).Color = [0 1 1];
                                    app.Callingapp.Callingapp.ROI_Binary.Parent.Children(end-indices(1)).Color = [0 1 1];
                                    app.Callingapp.Callingapp.ROI_NoTail.Parent.Children(end-indices(1)).Color = [0 1 1];
                                    app.Callingapp.Callingapp.ROI_Ellipse.Parent.Children(end-indices(1)-4).Color = [0 1 1];
                                case "yellow"
                                    s = uistyle('BackgroundColor',[1 1 0]);
                                    app.UIAxes.Children(end-indices(1)).Color = [1 1 0];
                                    app.Callingapp.Callingapp.ROI_Raw.Parent.Children(end-indices(1)).Color = [1 1 0];
                                    app.Callingapp.Callingapp.ROI_Binary.Parent.Children(end-indices(1)).Color = [1 1 0];
                                    app.Callingapp.Callingapp.ROI_NoTail.Parent.Children(end-indices(1)).Color = [1 1 0];
                                    app.Callingapp.Callingapp.ROI_Ellipse.Parent.Children(end-indices(1)-4).Color = [1 1 0];
                                case "other"
                                    app.UITable.ColumnFormat= {'logical','logical','logical', 'char', 'char', 'numeric', 'numeric', 'numeric'};
                                    app.UITable.Data(indices(1),5) = event.Source.Data(indices(1),indices(2)) ;
                                    s = uistyle('BackgroundColor',str2num(app.UITable.Data(indices(1),indices(2))));
                                    app.UIAxes.Children(end-indices(1)).Color = str2num(app.UITable.Data(indices(1),indices(2)));
                                    app.Callingapp.Callingapp.ROI_Raw.Parent.Children(end-indices(1)).Color = str2num(app.UITable.Data(indices(1),indices(2)));
                                    app.Callingapp.Callingapp.ROI_Binary.Parent.Children(end-indices(1)).Color = str2num(app.UITable.Data(indices(1),indices(2)));
                                    app.Callingapp.Callingapp.ROI_NoTail.Parent.Children(end-indices(1)).Color = str2num(app.UITable.Data(indices(1),indices(2)));
                                    app.Callingapp.Callingapp.ROI_Ellipse.Parent.Children(end-indices(1)-4).Color = str2num(app.UITable.Data(indices(1),indices(2)));
                                otherwise
                                    app.UITable.Data(indices(1),5) = event.Source.Data(indices(1),indices(2)) ;
                                    s = uistyle('BackgroundColor',str2num(app.UITable.Data(indices(1),indices(2))));
                                    app.UIAxes.Children(end-indices(1)).Color = str2num(app.UITable.Data(indices(1),indices(2)));
                                    app.Callingapp.Callingapp.ROI_Raw.Parent.Children(end-indices(1)).Color = str2num(app.UITable.Data(indices(1),indices(2)));
                                    app.Callingapp.Callingapp.ROI_Binary.Parent.Children(end-indices(1)).Color = str2num(app.UITable.Data(indices(1),indices(2)));
                                    app.Callingapp.Callingapp.ROI_NoTail.Parent.Children(end-indices(1)).Color = str2num(app.UITable.Data(indices(1),indices(2)));
                                    app.Callingapp.Callingapp.ROI_Ellipse.Parent.Children(end-indices(1)-4).Color = str2num(app.UITable.Data(indices(1),indices(2)));
                                    app.UITable.ColumnFormat= {'logical','logical','logical', 'char', {'red', 'green', 'blue', 'magenta','cyan','yellow','other'}, 'numeric', 'numeric', 'numeric'};
                            end
                            addStyle(app.UITable,s,"cell",[indices(1),5]);
                        end


                        % Update Positions
                        if indices(2) == 6
                            app.Callingapp.Callingapp.ROI.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).Position(1) = double(app.UITable.Data(indices(1),6));
                            app.Callingapp.Callingapp.ROI_Raw.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).Position(1) = double(app.UITable.Data(indices(1),6));
                            app.Callingapp.Callingapp.ROI_Binary.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).Position(1) = double(app.UITable.Data(indices(1),6));
                            app.Callingapp.Callingapp.ROI_NoTail.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).Position(1) = double(app.UITable.Data(indices(1),6));
                            app.Callingapp.Callingapp.ROI_Ellipse.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).Position(1) = double(app.UITable.Data(indices(1),6));
                        end

                        if indices(2) == 7
                            app.Callingapp.Callingapp.ROI.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).Position(2) = double(app.UITable.Data(indices(1),7));
                            app.Callingapp.Callingapp.ROI_Raw.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).Position(2) = double(app.UITable.Data(indices(1),7));
                            app.Callingapp.Callingapp.ROI_Binary.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).Position(2) = double(app.UITable.Data(indices(1),7));
                            app.Callingapp.Callingapp.ROI_NoTail.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).Position(2) = double(app.UITable.Data(indices(1),7));
                            app.Callingapp.Callingapp.ROI_Ellipse.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).Position(2) = double(app.UITable.Data(indices(1),7));
                        end

                        % Update Rectangle Size

                        if indices(2) == 8
                            app.Callingapp.Callingapp.ROI.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).Position(3) = double(app.UITable.Data(indices(1),8));
                            app.Callingapp.Callingapp.ROI_Raw.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).Position(3) = double(app.UITable.Data(indices(1),8));
                            app.Callingapp.Callingapp.ROI_Binary.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).Position(3) = double(app.UITable.Data(indices(1),8));
                            app.Callingapp.Callingapp.ROI_NoTail.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).Position(3) = double(app.UITable.Data(indices(1),8));
                            app.Callingapp.Callingapp.ROI_Ellipse.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).Position(3) = double(app.UITable.Data(indices(1),8));
                        end

                        if indices(2) == 9
                            app.Callingapp.Callingapp.ROI.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).Position(4) = double(app.UITable.Data(indices(1),9));
                            app.Callingapp.Callingapp.ROI_Raw.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).Position(4) = double(app.UITable.Data(indices(1),9));
                            app.Callingapp.Callingapp.ROI_Binary.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).Position(4) = double(app.UITable.Data(indices(1),9));
                            app.Callingapp.Callingapp.ROI_NoTail.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).Position(4) = double(app.UITable.Data(indices(1),9));
                            app.Callingapp.Callingapp.ROI_Ellipse.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).Position(4) = double(app.UITable.Data(indices(1),9));
                        end

                        if indices(2) == 6||7||8||9
                            app.Callingapp.Callingapp.ROI.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).InteractionsAllowed='none';
                            app.Callingapp.Callingapp.ROI.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).FaceSelectable=0;
                            app.Callingapp.Callingapp.ROI_Raw.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).InteractionsAllowed='none';
                            app.Callingapp.Callingapp.ROI_Binary.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).InteractionsAllowed='none';
                            app.Callingapp.Callingapp.ROI_NoTail.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).InteractionsAllowed='none';
                            app.Callingapp.Callingapp.ROI_Ellipse.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).InteractionsAllowed='none';
                            app.Callingapp.Callingapp.ROI_Raw.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).FaceSelectable=0;
                            app.Callingapp.Callingapp.ROI_Binary.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).FaceSelectable=0;
                            app.Callingapp.Callingapp.ROI_NoTail.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).FaceSelectable=0;
                            app.Callingapp.Callingapp.ROI_Ellipse.Parent.Children(size(app.UITable.Data,1)-indices(1)+1).FaceSelectable=0;
                        end
                    end
                end
                app.Callingapp.Callingapp.ROI_Data = app.UITable.Data;
        end

        % Menu selected function: CreateNewROIMenu
        function CreateNewROIMenuSelected(app, event)
          
        end

        % Menu selected function: DeleteSelectedROIsMenu
        function DeleteSelectedROIsMenuSelected(app, event)
            app.UITable.Data=app.UITable.DisplayData(~strcmp(app.UITable.DisplayData(:,1),"1"),:);
            
           try
            % Remove old ROIs 
            delete(app.UIAxes.Children(1:end-1))
            delete(app.Callingapp.Callingapp.ROI_Raw.Parent.Children(1:end-1))
            delete(app.Callingapp.Callingapp.ROI_Binary.Parent.Children(1:end-1))
            delete(app.Callingapp.Callingapp.ROI_NoTail.Parent.Children(1:end-1))
            delete(app.Callingapp.Callingapp.ROI_Ellipse.Parent.Children(1:end-5))
           end

            % Reset ROI count
            app.ROIcount = size(app.UITable.Data,1);

            % Create rectangles
            for ii = 1:size(app.UITable.Data,1)
                try isstring(app.UITable.Data(ii,5));
                    s = uistyle('BackgroundColor',app.UITable.Data(ii,5));
                    addStyle(app.UITable,s,"cell",[ii,5]);
                    app.Callingapp.Callingapp.ROI = drawrectangle(app.UIAxes,'Position',str2num(char(app.UITable.Data(ii,6:9)'))','Color',app.UITable.Data(ii,5),'Tag',num2str(ii));%num2str(size(app.UITable.Data,1)+1-ii));%
                    addlistener(app.Callingapp.Callingapp.ROI,'MovingROI',@ROIevents);
                    addlistener(app.Callingapp.Callingapp.ROI,'ROIMoved',@ROIevents);
                    app.Callingapp.Callingapp.ROI_Raw = drawrectangle(app.Callingapp.RawAxes,'Position',app.Callingapp.Callingapp.ROI.Position,'Color',app.UITable.Data(ii,5));
                    app.Callingapp.Callingapp.ROI_Binary = drawrectangle(app.Callingapp.BinaryAxes,"Position",app.Callingapp.Callingapp.ROI.Position,'Color',app.UITable.Data(ii,5));
                    app.Callingapp.Callingapp.ROI_NoTail = drawrectangle(app.Callingapp.NoTailAxes,"Position",app.Callingapp.Callingapp.ROI.Position,'Color',app.UITable.Data(ii,5));
                    app.Callingapp.Callingapp.ROI_Ellipse = drawrectangle(app.Callingapp.EllipseAxes,"Position",app.Callingapp.Callingapp.ROI.Position,'Color',app.UITable.Data(ii,5));
                catch
                    delete(app.UIAxes.Children(1))
                    s = uistyle('BackgroundColor',str2num(app.UITable.Data(ii,5)));
                    addStyle(app.UITable,s,"cell",[ii,5]);
                    app.Callingapp.Callingapp.ROI = drawrectangle(app.UIAxes,'Position',str2num(char(app.UITable.Data(ii,6:9)'))','Color',str2num(app.UITable.Data(ii,5)),'Tag',num2str(ii));%num2str(size(app.UITable.Data,1)+1-ii));%
                    addlistener(app.Callingapp.Callingapp.ROI,'MovingROI',@ROIevents);
                    addlistener(app.Callingapp.Callingapp.ROI,'ROIMoved',@ROIevents);
                    app.Callingapp.Callingapp.ROI_Raw = drawrectangle(app.Callingapp.RawAxes,'Position',app.Callingapp.Callingapp.ROI.Position,'Color',str2num(app.UITable.Data(ii,5)));
                    app.Callingapp.Callingapp.ROI_Binary = drawrectangle(app.Callingapp.BinaryAxes,"Position",app.Callingapp.Callingapp.ROI.Position,'Color',str2num(app.UITable.Data(ii,5)));
                    app.Callingapp.Callingapp.ROI_NoTail = drawrectangle(app.Callingapp.NoTailAxes,"Position",app.Callingapp.Callingapp.ROI.Position,'Color',str2num(app.UITable.Data(ii,5)));
                    app.Callingapp.Callingapp.ROI_Ellipse = drawrectangle(app.Callingapp.EllipseAxes,"Position",app.Callingapp.Callingapp.ROI.Position,'Color',str2num(app.UITable.Data(ii,5)));
                end
%                 if app.UITable.Data(ii,1) ~= "1"
                    app.Callingapp.Callingapp.ROI.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_Raw.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_Binary.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_NoTail.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_Ellipse.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_Raw.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_Binary.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_NoTail.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_Ellipse.FaceSelectable=0;
%                 end
            end

            
                

            app.Callingapp.Callingapp.ROI_Data = app.UITable.Data;

        end

        % Button pushed function: GenerateROIsButton
        function GenerateROIsButtonPushed(app, event)
            Image_size=size(app.UIAxes.Children(end).CData);

            figure
            cmap = colormap(app.ColormapDropDown.Value);
            close(gcf)
            n = app.widthEditField.Value;
            m = app.heightEditField.Value;
            numberofgridrectangles = n*m;

            app.UITable.ColumnFormat= {'logical','logical','logical', 'char', {'red', 'green', 'blue', 'magenta','cyan','yellow','other'}, 'numeric', 'numeric', 'numeric'};

            for jj=0:1:n-1
                for kk=0:1:m-1
                    app.ROIcount = app.ROIcount+1;
                    app.Callingapp.Callingapp.ROI = drawrectangle(app.UIAxes,'Position',[(Image_size(1)/n)*jj (Image_size(1)/m)*kk Image_size(1)/n Image_size(1)/m],'Color',cmap(ceil((Image_size(1)/(n*m))*numberofgridrectangles),:),'Tag',num2str(app.ROIcount));
                    addlistener(app.Callingapp.Callingapp.ROI,'MovingROI',@ROIevents);
                    addlistener(app.Callingapp.Callingapp.ROI,'ROIMoved',@ROIevents);
                    app.Callingapp.Callingapp.ROI_Raw = drawrectangle(app.Callingapp.RawAxes,'Position',app.Callingapp.Callingapp.ROI.Position,'Color',app.Callingapp.Callingapp.ROI.Color);
                    app.Callingapp.Callingapp.ROI_Binary = drawrectangle(app.Callingapp.BinaryAxes,'Position',app.Callingapp.Callingapp.ROI.Position,'Color',app.Callingapp.Callingapp.ROI.Color);
                    app.Callingapp.Callingapp.ROI_NoTail = drawrectangle(app.Callingapp.NoTailAxes,'Position',app.Callingapp.Callingapp.ROI.Position,'Color',app.Callingapp.Callingapp.ROI.Color);
                    app.Callingapp.Callingapp.ROI_Ellipse = drawrectangle(app.Callingapp.EllipseAxes,'Position',app.Callingapp.Callingapp.ROI.Position,'Color',app.Callingapp.Callingapp.ROI.Color);
                    
                    app.Callingapp.Callingapp.ROI.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_Raw.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_Binary.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_NoTail.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_Ellipse.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_Raw.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_Binary.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_NoTail.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_Ellipse.FaceSelectable=0;
                    
                    
                    
                    if isempty(app.UITable.Data)
                        app.UITable.Data = " ";
                    end
%                     app.Callingapp.Callingapp.ROI.Tag = num2str(app.ROIcount);
                    app.UITable.Data(app.ROIcount,2) = 1;
                    app.UITable.Data(app.ROIcount,3) = 0;
                    app.UITable.Data(app.ROIcount,4) = ['Grid ' num2str(app.ROIcount)];
                    app.UITable.Data(app.ROIcount,5) = num2str(cmap(ceil((Image_size(1)/(n*m))*numberofgridrectangles),:));
                    s = uistyle('BackgroundColor',cmap(ceil((Image_size(1)/(n*m))*numberofgridrectangles),:));
                    addStyle(app.UITable,s,"cell",[app.ROIcount,5]);
                    app.UITable.Data(app.ROIcount,6:9) = app.Callingapp.Callingapp.ROI.Position;
                    numberofgridrectangles = numberofgridrectangles-1;
                               
                end
            end
            app.UITable.ColumnFormat= {'logical','logical','logical', 'char', {'red', 'green', 'blue', 'magenta','cyan','yellow','other'}, 'numeric', 'numeric', 'numeric'};
            app.Callingapp.Callingapp.ROI_Data = app.UITable.Data;
        end

        % Cell selection callback: UITable
        function UITableCellSelection(app, event)
            indices = event.Indices;
            if indices(1,2)==1
                if sum(app.UITable.Data(indices,1)~="1")>0
                    app.UITable.Data(indices,1)=1;
                end
            elseif indices(1,2)==1
                app.UITable.Data(indices,1)=0;
            end
        end

        % Close request function: 
        % RodentTrackerRegionofInterestSelectionUIFigure
        function RodentTrackerRegionofInterestSelectionUIFigureCloseRequest(app, event)
            app.RodentTrackerRegionofInterestSelectionUIFigure.Visible ="off";
            app.Callingapp.ROISelectorMenu.Checked = "off";
            app.Callingapp.Callingapp.ROISelectorMenu.Checked = "off";
        end

        % Button pushed function: CombineButton
        function CombineButtonPushed(app, event)
            x = min(str2double(app.UITable.Data(str2double(app.UITable.Data(:,1))==1,6)));
            y = min(str2double(app.UITable.Data(str2double(app.UITable.Data(:,1))==1,7)));

            x_max = max(str2double(app.UITable.Data(str2double(app.UITable.Data(:,1))==1,6))+str2double(app.UITable.Data(str2double(app.UITable.Data(:,1))==1,8)));
            y_max = max(str2double(app.UITable.Data(str2double(app.UITable.Data(:,1))==1,7))+str2double(app.UITable.Data(str2double(app.UITable.Data(:,1))==1,9)));
            w = x_max-x;
            h = y_max-y;



            app.Callingapp.Callingapp.ROI = drawrectangle(app.UIAxes,"Color",'magenta',"Position",[x y w h]);

            addlistener(app.Callingapp.Callingapp.ROI,'MovingROI',@ROIevents);
            addlistener(app.Callingapp.Callingapp.ROI,'ROIMoved',@ROIevents);


            app.ROIcount = app.ROIcount+1;
            if isempty(app.UITable.Data)
                app.UITable.Data = " ";
            end
            app.Callingapp.Callingapp.ROI.Tag = num2str(app.ROIcount);
            app.UITable.Data(app.ROIcount,2) = 1;
            app.UITable.Data(app.ROIcount,3) = 0;
            app.UITable.Data(app.ROIcount,4) = "Combined ROI";
            app.UITable.Data(app.ROIcount,5) = "magenta";
            s = uistyle('BackgroundColor',[1 0 1]);
            addStyle(app.UITable,s,"cell",[app.ROIcount,5]);
            app.UITable.Data(app.ROIcount,6:9) = app.Callingapp.Callingapp.ROI.Position;

            DeleteSelectedROIsMenuSelected(app)
        end

        % Menu selected function: ElevatedPlusMazeMenu
        function ElevatedPlusMazeMenuSelected(app, event)
            EPMButtonPushed(app)
        end

        % Button pushed function: EPMButton
        function EPMButtonPushed(app, event)
            if app.EPMButton.Text == "EPM"
                app.EPMButton.Text = "Set Center ROI";
                app.Callingapp.Callingapp.ROI = drawrectangle(app.UIAxes,"Color",'yellow');

                addlistener(app.Callingapp.Callingapp.ROI,'MovingROI',@ROIevents);
                addlistener(app.Callingapp.Callingapp.ROI,'ROIMoved',@ROIevents);

                app.ROIcount = app.ROIcount+1;
                if isempty(app.UITable.Data)
                app.UITable.Data = " ";
                end
                app.Callingapp.Callingapp.ROI.Tag = num2str(app.ROIcount);
                app.UITable.Data(app.ROIcount,2) = 1;
                app.UITable.Data(app.ROIcount,3) = 0;
                app.UITable.Data(app.ROIcount,4) = "Center";
                app.UITable.Data(app.ROIcount,5) = "yellow";
                s = uistyle('BackgroundColor',[1 1 0]);
                addStyle(app.UITable,s,"cell",[app.ROIcount,5]);
                app.UITable.Data(app.ROIcount,6:9) = app.Callingapp.Callingapp.ROI.Position;

            else
                app.EPMButton.Text = "EPM";
                app.Callingapp.Callingapp.ROI.InteractionsAllowed='none';
                app.Callingapp.Callingapp.ROI.FaceSelectable=0;
                % Copies of Center ROI
                app.Callingapp.Callingapp.ROI_Raw = drawrectangle(app.Callingapp.RawAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                app.Callingapp.Callingapp.ROI_Binary = drawrectangle(app.Callingapp.BinaryAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                app.Callingapp.Callingapp.ROI_NoTail = drawrectangle(app.Callingapp.NoTailAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                app.Callingapp.Callingapp.ROI_Ellipse = drawrectangle(app.Callingapp.EllipseAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                app.Callingapp.Callingapp.ROI_Raw.InteractionsAllowed='none';
                app.Callingapp.Callingapp.ROI_Binary.InteractionsAllowed='none';
                app.Callingapp.Callingapp.ROI_NoTail.InteractionsAllowed='none';
                app.Callingapp.Callingapp.ROI_Ellipse.InteractionsAllowed='none';
                app.Callingapp.Callingapp.ROI_Raw.FaceSelectable=0;
                app.Callingapp.Callingapp.ROI_Binary.FaceSelectable=0;
                app.Callingapp.Callingapp.ROI_NoTail.FaceSelectable=0;
                app.Callingapp.Callingapp.ROI_Ellipse.FaceSelectable=0;

                x = app.Callingapp.Callingapp.ROI.Position(1);
                y = app.Callingapp.Callingapp.ROI.Position(2);
                w = app.Callingapp.Callingapp.ROI.Position(3);
                h = app.Callingapp.Callingapp.ROI.Position(4);
                W = size(app.UIAxes.Children(end).CData,1);
                H = size(app.UIAxes.Children(end).CData,2);

                % North
                    app.Callingapp.Callingapp.ROI = drawrectangle(app.UIAxes,"Color",'cyan',"Position",[x 0 w y]);%round((H-h)/2)
                    addlistener(app.Callingapp.Callingapp.ROI,'MovingROI',@ROIevents);
                    addlistener(app.Callingapp.Callingapp.ROI,'ROIMoved',@ROIevents);
                    app.Callingapp.Callingapp.ROI.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI.FaceSelectable=0;

                    app.ROIcount = app.ROIcount+1;
                    app.Callingapp.Callingapp.ROI.Tag = num2str(app.ROIcount);
                    app.UITable.Data(app.ROIcount,2) = 1;
                    app.UITable.Data(app.ROIcount,3) = 0;
                    app.UITable.Data(app.ROIcount,4) = "North";
                    app.UITable.Data(app.ROIcount,5) = "cyan";
                    s = uistyle('BackgroundColor',[0 1 1]);
                    addStyle(app.UITable,s,"cell",[app.ROIcount,5]);
                    app.UITable.Data(app.ROIcount,6:9) = [x 0 w y];

                    app.Callingapp.Callingapp.ROI_Raw = drawrectangle(app.Callingapp.RawAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                    app.Callingapp.Callingapp.ROI_Binary = drawrectangle(app.Callingapp.BinaryAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                    app.Callingapp.Callingapp.ROI_NoTail = drawrectangle(app.Callingapp.NoTailAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                    app.Callingapp.Callingapp.ROI_Ellipse = drawrectangle(app.Callingapp.EllipseAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                    app.Callingapp.Callingapp.ROI_Raw.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_Binary.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_NoTail.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_Ellipse.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_Raw.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_Binary.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_NoTail.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_Ellipse.FaceSelectable=0;

                % South
                    app.Callingapp.Callingapp.ROI = drawrectangle(app.UIAxes,"Color",'green',"Position",[x y+h w H-(y+h)]);
                    addlistener(app.Callingapp.Callingapp.ROI,'MovingROI',@ROIevents);
                    addlistener(app.Callingapp.Callingapp.ROI,'ROIMoved',@ROIevents);
                    app.Callingapp.Callingapp.ROI.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI.FaceSelectable=0;
                    
                    app.ROIcount = app.ROIcount+1;
                    app.Callingapp.Callingapp.ROI.Tag = num2str(app.ROIcount);
                    app.UITable.Data(app.ROIcount,2) = 1;
                    app.UITable.Data(app.ROIcount,3) = 0;
                    app.UITable.Data(app.ROIcount,4) = "South";
                    app.UITable.Data(app.ROIcount,5) = "green";
                    s = uistyle('BackgroundColor',[0 1 0]);
                    addStyle(app.UITable,s,"cell",[app.ROIcount,5]);
                    app.UITable.Data(app.ROIcount,6:9) = [x y+h w H-(y+h)];%round((H-h)/2)

                    app.Callingapp.Callingapp.ROI_Raw = drawrectangle(app.Callingapp.RawAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                    app.Callingapp.Callingapp.ROI_Binary = drawrectangle(app.Callingapp.BinaryAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                    app.Callingapp.Callingapp.ROI_NoTail = drawrectangle(app.Callingapp.NoTailAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                    app.Callingapp.Callingapp.ROI_Ellipse = drawrectangle(app.Callingapp.EllipseAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                    app.Callingapp.Callingapp.ROI_Raw.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_Binary.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_NoTail.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_Ellipse.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_Raw.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_Binary.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_NoTail.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_Ellipse.FaceSelectable=0;

                % East
                    app.Callingapp.Callingapp.ROI = drawrectangle(app.UIAxes,"Color",'red',"Position",[x+w y W-(x+w) h]);
                    addlistener(app.Callingapp.Callingapp.ROI,'MovingROI',@ROIevents);
                    addlistener(app.Callingapp.Callingapp.ROI,'ROIMoved',@ROIevents);
                    app.Callingapp.Callingapp.ROI.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI.FaceSelectable=0;
                    
                    app.ROIcount = app.ROIcount+1;
                    app.Callingapp.Callingapp.ROI.Tag = num2str(app.ROIcount);
                    app.UITable.Data(app.ROIcount,2) = 1;
                    app.UITable.Data(app.ROIcount,3) = 0;
                    app.UITable.Data(app.ROIcount,4) = "East";
                    app.UITable.Data(app.ROIcount,5) = "red";
                    s = uistyle('BackgroundColor',[1 0 0]);
                    addStyle(app.UITable,s,"cell",[app.ROIcount,5]);
                    app.UITable.Data(app.ROIcount,6:9) = [x+w y W-(x+w) h];

                    app.Callingapp.Callingapp.ROI_Raw = drawrectangle(app.Callingapp.RawAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                    app.Callingapp.Callingapp.ROI_Binary = drawrectangle(app.Callingapp.BinaryAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                    app.Callingapp.Callingapp.ROI_NoTail = drawrectangle(app.Callingapp.NoTailAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                    app.Callingapp.Callingapp.ROI_Ellipse = drawrectangle(app.Callingapp.EllipseAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                    app.Callingapp.Callingapp.ROI_Raw.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_Binary.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_NoTail.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_Ellipse.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_Raw.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_Binary.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_NoTail.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_Ellipse.FaceSelectable=0;

                % West
                    app.Callingapp.Callingapp.ROI = drawrectangle(app.UIAxes,"Color",'blue',"Position",[0 y x h]);
                    addlistener(app.Callingapp.Callingapp.ROI,'MovingROI',@ROIevents);
                    addlistener(app.Callingapp.Callingapp.ROI,'ROIMoved',@ROIevents);
                    app.Callingapp.Callingapp.ROI.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI.FaceSelectable=0;
                    
                    app.ROIcount = app.ROIcount+1;
                    app.Callingapp.Callingapp.ROI.Tag = num2str(app.ROIcount);
                    app.UITable.Data(app.ROIcount,2) = 1;
                    app.UITable.Data(app.ROIcount,3) = 0;
                    app.UITable.Data(app.ROIcount,4) = "West";
                    app.UITable.Data(app.ROIcount,5) = "blue";
                    s = uistyle('BackgroundColor',[0 0 1]);
                    addStyle(app.UITable,s,"cell",[app.ROIcount,5]);
                    app.UITable.Data(app.ROIcount,6:9) = [0 y x h];%round((W-w)/2)

                    app.Callingapp.Callingapp.ROI_Raw = drawrectangle(app.Callingapp.RawAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                    app.Callingapp.Callingapp.ROI_Binary = drawrectangle(app.Callingapp.BinaryAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                    app.Callingapp.Callingapp.ROI_NoTail = drawrectangle(app.Callingapp.NoTailAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                    app.Callingapp.Callingapp.ROI_Ellipse = drawrectangle(app.Callingapp.EllipseAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                    app.Callingapp.Callingapp.ROI_Raw.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_Binary.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_NoTail.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_Ellipse.InteractionsAllowed='none';
                    app.Callingapp.Callingapp.ROI_Raw.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_Binary.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_NoTail.FaceSelectable=0;
                    app.Callingapp.Callingapp.ROI_Ellipse.FaceSelectable=0;

%                     app.Callingapp.Callingapp.ROI_Data = app.UITable.Data;
            end
            app.UITable.ColumnFormat= {'logical','logical','logical', 'char', {'red', 'green', 'blue', 'magenta','cyan','yellow','other'}, 'numeric', 'numeric', 'numeric'};
            app.Callingapp.Callingapp.ROI_Data = app.UITable.Data;
        end

        % Button pushed function: OFButton
        function OFButtonPushed(app, event)
            Image_size=size(app.UIAxes.Children(end).CData);
            
            if app.OFButton.Text == "OF"
                app.OFButton.Text = "Set Center ROI";
                app.Callingapp.Callingapp.ROI = drawrectangle(app.UIAxes,"Color",'magenta','Position',[round(Image_size(1)/4) round(Image_size(2)/4) round(0.5*Image_size(1)) round(0.5*Image_size(2))]);

                addlistener(app.Callingapp.Callingapp.ROI,'MovingROI',@ROIevents);
                addlistener(app.Callingapp.Callingapp.ROI,'ROIMoved',@ROIevents);

                app.ROIcount = app.ROIcount+1;
                if isempty(app.UITable.Data)
                app.UITable.Data = " ";
                end
                app.Callingapp.Callingapp.ROI.Tag = num2str(app.ROIcount);
                app.UITable.Data(app.ROIcount,2) = 1;
                app.UITable.Data(app.ROIcount,3) = 0;
                app.UITable.Data(app.ROIcount,4) = "Center";
                app.UITable.Data(app.ROIcount,5) = "magenta";
                s = uistyle('BackgroundColor',[1 0 1]);
                addStyle(app.UITable,s,"cell",[app.ROIcount,5]);
                app.UITable.Data(app.ROIcount,6:9) = app.Callingapp.Callingapp.ROI.Position;

            else
                app.OFButton.Text = "OF";
                app.Callingapp.Callingapp.ROI.InteractionsAllowed='none';
                app.Callingapp.Callingapp.ROI.FaceSelectable=0;
                % Copies of Center ROI
                app.Callingapp.Callingapp.ROI_Raw = drawrectangle(app.Callingapp.RawAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                app.Callingapp.Callingapp.ROI_Binary = drawrectangle(app.Callingapp.BinaryAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                app.Callingapp.Callingapp.ROI_NoTail = drawrectangle(app.Callingapp.NoTailAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                app.Callingapp.Callingapp.ROI_Ellipse = drawrectangle(app.Callingapp.EllipseAxes,"Position",app.Callingapp.Callingapp.ROI.Position,"Color",app.UITable.Data(app.ROIcount,5));
                app.Callingapp.Callingapp.ROI_Raw.InteractionsAllowed='none';
                app.Callingapp.Callingapp.ROI_Binary.InteractionsAllowed='none';
                app.Callingapp.Callingapp.ROI_NoTail.InteractionsAllowed='none';
                app.Callingapp.Callingapp.ROI_Ellipse.InteractionsAllowed='none';
                app.Callingapp.Callingapp.ROI_Raw.FaceSelectable=0;
                app.Callingapp.Callingapp.ROI_Binary.FaceSelectable=0;
                app.Callingapp.Callingapp.ROI_NoTail.FaceSelectable=0;
                app.Callingapp.Callingapp.ROI_Ellipse.FaceSelectable=0;
                
            end

            app.UITable.ColumnFormat= {'logical','logical','logical', 'char', {'red', 'green', 'blue', 'magenta','cyan','yellow','other'}, 'numeric', 'numeric', 'numeric'};
            app.Callingapp.Callingapp.ROI_Data = app.UITable.Data;
        end

        % Menu selected function: OpenFieldMenu
        function OpenFieldMenuSelected(app, event)
            OFButtonPushed(app)
        end
    end

    % App creation
    methods (Access = public)

        % Construct app
        function app = RodentTracker_ROI_Window(varargin)
            app = app@matlab.apps.App(varargin{:});

            if nargout == 0
                clear app
            end
        end
    end
end