classdef RodentTracker_Video_Window < matlab.apps.App

    % Used to locate and load the app's XML configuration file
    properties (Access = public, Constant)
        AppConfigFilename = './RodentTracker_Video_Window.xml'; % File path to the app configuration file containing component layout and settings
    end

    % Properties that correspond to app components
    properties (Access = public)
        RodentTrackerAnalysisPreviewUIFigure  matlab.ui.Figure
        FileMenu                        matlab.ui.container.Menu
        SaveasMenu                      matlab.ui.container.Menu
        EditMenu                        matlab.ui.container.Menu
        EllipseMenu                     matlab.ui.container.Menu
        EllipseColor                    matlab.ui.container.Menu
        CentroidMenu                    matlab.ui.container.Menu
        CentroidColor                   matlab.ui.container.Menu
        TailpointMenu                   matlab.ui.container.Menu
        TailpointColor                  matlab.ui.container.Menu
        HeadpointMenu                   matlab.ui.container.Menu
        HeadpointColor                  matlab.ui.container.Menu
        ViewMenu                        matlab.ui.container.Menu
        ROISelectorMenu                 matlab.ui.container.Menu
        GridLayout                      matlab.ui.container.GridLayout
        EllipseAxes                     matlab.ui.control.UIAxes
        NoTailAxes                      matlab.ui.control.UIAxes
        BinaryAxes                      matlab.ui.control.UIAxes
        RawAxes                         matlab.ui.control.UIAxes
    end

    properties (Access = public)
        Callingapp
        ROI
        ROI_Window
    end    

    % Callbacks that handle component events
    methods

        % Code that executes after component creation
        function startupFcn(app, Mainapp)
            %Position
            screen = get(0,'screensize');
            xres = screen(3)-screen(1);
            yres = screen(4)-screen(2);

            %Position
            app.RodentTrackerAnalysisPreviewUIFigure.Units = 'normalized';
            app.RodentTrackerAnalysisPreviewUIFigure.Position = [0.06 0.06 .47*(yres/xres) 0.42];%
            app.RodentTrackerAnalysisPreviewUIFigure.Units = 'pixels';

            app.Callingapp = Mainapp;

            app.ROI_Window = RodentTracker_ROI_Window(app);
        end

        % Close request function: RodentTrackerAnalysisPreviewUIFigure
        function RodentTrackerAnalysisPreviewUIFigureCloseRequest(app, event)
            app.RodentTrackerAnalysisPreviewUIFigure.Visible ="off";
            app.Callingapp.VideoWindowMenu.Checked = "off";
        end

        % Menu selected function: EllipseColor
        function EllipseColorMenuSelected(app, event)
            app.Callingapp.EllipseColor = uisetcolor;
            app.EllipseAxes.Children(4).Color = app.Callingapp.EllipseColor;

            figure(app.RodentTrackerAnalysisPreviewUIFigure)
            figure(app.Callingapp.Trace_Window.RodentTrackerTraceUIFigure)
            figure(app.Callingapp.Spreadsheet_Window.RodentTrackerSpreadsheetUIFigure)
            figure(app.Callingapp.RodentTrackerUIFigure)
        end

        % Menu selected function: CentroidColor
        function CentroidColorMenuSelected(app, event)
            app.Callingapp.CentroidColor = uisetcolor;
            app.EllipseAxes.Children(3).MarkerFaceColor = app.Callingapp.CentroidColor;
            app.EllipseAxes.Children(3).MarkerEdgeColor = app.Callingapp.CentroidColor;

            figure(app.RodentTrackerAnalysisPreviewUIFigure)
            figure(app.Callingapp.Trace_Window.RodentTrackerTraceUIFigure)
            figure(app.Callingapp.Spreadsheet_Window.RodentTrackerSpreadsheetUIFigure)
            figure(app.Callingapp.RodentTrackerUIFigure)
        end

        % Menu selected function: TailpointColor
        function TailpointColorMenuSelected(app, event)
            app.Callingapp.TailpointColor = uisetcolor;
            app.EllipseAxes.Children(2).MarkerFaceColor = app.Callingapp.TailpointColor;
            app.EllipseAxes.Children(2).MarkerEdgeColor = app.Callingapp.TailpointColor;

            figure(app.RodentTrackerAnalysisPreviewUIFigure)
            figure(app.Callingapp.Trace_Window.RodentTrackerTraceUIFigure)
            figure(app.Callingapp.Spreadsheet_Window.RodentTrackerSpreadsheetUIFigure)
            figure(app.Callingapp.RodentTrackerUIFigure)
        end

        % Menu selected function: HeadpointColor
        function HeadpointColorMenuSelected(app, event)
            app.Callingapp.HeadpointColor = uisetcolor;
            app.EllipseAxes.Children(1).MarkerFaceColor = app.Callingapp.HeadpointColor;
            app.EllipseAxes.Children(1).MarkerEdgeColor = app.Callingapp.HeadpointColor;

            figure(app.RodentTrackerAnalysisPreviewUIFigure)
            figure(app.Callingapp.Trace_Window.RodentTrackerTraceUIFigure)
            figure(app.Callingapp.Spreadsheet_Window.RodentTrackerSpreadsheetUIFigure)
            figure(app.Callingapp.RodentTrackerUIFigure)
        end

        % Menu selected function: SaveasMenu
        function SaveasMenuSelected(app, event)
            app.Callingapp.ProgressText.Text = 'Saving Analysis Preview...';
            filter = {'*.jpg';'*.png'};
            [file,path] = uiputfile(filter);
            filename = fullfile(path,file);
            AP_Image = getframe(app.RodentTrackerAnalysisPreviewUIFigure);
            AP_Image = AP_Image.cdata;
            imwrite(AP_Image, filename);
            app.Callingapp.ProgressText.Text = 'Analysis Preview Saved';
        end

        % Callback function
        function SetMenuSelected(app, event)
            app.Callingapp.ROI.InteractionsAllowed='none';
            app.Callingapp.ROI.FaceSelectable=0;
            drawrectangle(app.BinaryAxes,"Position",app.Callingapp.ROI.Position)
            drawrectangle(app.NoTailAxes,"Position",app.Callingapp.ROI.Position)
            drawrectangle(app.EllipseAxes,"Position",app.Callingapp.ROI.Position)
        end

        % Menu selected function: ROISelectorMenu
        function ROISelectorMenuSelected(app, event)
            if app.ROI_Window.RodentTrackerRegionofInterestSelectionUIFigure.Visible == "on"
                app.ROI_Window.RodentTrackerRegionofInterestSelectionUIFigure.Visible = "off";
                app.ROISelectorMenu.Checked = "off";
                app.Callingapp.ROISelectorMenu.Checked = "off";
            else
                app.ROI_Window.RodentTrackerRegionofInterestSelectionUIFigure.Visible = "on";
                app.ROISelectorMenu.Checked = "on";
                app.Callingapp.ROISelectorMenu.Checked = "on";
                if isempty(app.ROI_Window.UIAxes.Children)
                    imshow(app.RawAxes.Children(end).CData,'Parent',app.ROI_Window.UIAxes)
                    app.ROI_Window.UIAxes.XLim = [0 size(app.RawAxes.Children(end).CData,1)];
                    app.ROI_Window.UIAxes.YLim = [0 size(app.RawAxes.Children(end).CData,2)];
                end
            end
        end
    end

    % App creation
    methods (Access = public)

        % Construct app
        function app = RodentTracker_Video_Window(varargin)
            app = app@matlab.apps.App(varargin{:});

            if nargout == 0
                clear app
            end
        end
    end
end