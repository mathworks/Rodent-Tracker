classdef RodentTracker_Trace_Window < matlab.apps.App

    % Used to locate and load the app's XML configuration file
    properties (Access = public, Constant)
        AppConfigFilename = './RodentTracker_Trace_Window.xml'; % File path to the app configuration file containing component layout and settings
    end

    % Properties that correspond to app components
    properties (Access = public)
        RodentTrackerTraceUIFigure      matlab.ui.Figure
        FileMenu                        matlab.ui.container.Menu
        SaveasMenu                      matlab.ui.container.Menu
        EditMenu                        matlab.ui.container.Menu
        ColorMenu                       matlab.ui.container.Menu
        ClearTraceMenu                  matlab.ui.container.Menu
        UIAxes                          matlab.ui.control.UIAxes
    end

    properties (Access = private)
        Callingapp
    end

    % Callbacks that handle component events
    methods

        % Code that executes after component creation
        function startupFcn(app, Mainapp)
            screen = get(0,'screensize');
            xres = screen(3)-screen(1);
            yres = screen(4)-screen(2);

            %Position
            app.RodentTrackerTraceUIFigure.Units = 'normalized';
            app.RodentTrackerTraceUIFigure.Position = [0.06+0.47*(yres/xres)+(((0.9426-0.47*(yres/xres)-(0.06+0.47*(yres/xres)))-0.47*(yres/xres))/2) 0.06 0.47*(yres/xres) 0.42];

            app.UIAxes.Units = 'normalized';
            app.UIAxes.Position = [0 0 1 1];
            axis(app.UIAxes,'ij')
            hold(app.UIAxes,"on")

            app.Callingapp = Mainapp;
        end

        % Close request function: RodentTrackerTraceUIFigure
        function RodentTrackerTraceUIFigureCloseRequest(app, event)
            app.RodentTrackerTraceUIFigure.Visible ="off";
            app.Callingapp.TraceWindowMenu.Checked = "off";
        end

        % Menu selected function: ColorMenu
        function ColorMenuSelected(app, event)
            app.Callingapp.TraceColor = uisetcolor;

            if ~isempty(app.UIAxes.Children)
            app.UIAxes.Children(1).MarkerFaceColor = app.Callingapp.TraceColor;
            app.UIAxes.Children(1).MarkerEdgeColor = app.Callingapp.TraceColor;
            end

            figure(app.Callingapp.Video_Window.RodentTrackerAnalysisPreviewUIFigure)
            figure(app.RodentTrackerTraceUIFigure)
            figure(app.Callingapp.Spreadsheet_Window.RodentTrackerSpreadsheetUIFigure)
            figure(app.Callingapp.RodentTrackerUIFigure)
        end

        % Menu selected function: ClearTraceMenu
        function ClearTraceMenuSelected(app, event)
            delete(app.UIAxes)
            % Create UIAxes
            app.UIAxes = uiaxes(app.RodentTrackerTraceUIFigure);
            app.UIAxes.PlotBoxAspectRatio = [1 1 1];
            app.UIAxes.XLim = [0 255];
            app.UIAxes.YLim = [0 255];
            app.UIAxes.ZLim = [0 1];
            app.UIAxes.XTick = [];
            app.UIAxes.YTick = [];
            app.UIAxes.ZTick = [];
            app.UIAxes.Color = [0 0 0];
            app.UIAxes.TickDir = 'none';
            app.UIAxes.Position = [0 0 400 400];
            axis(app.UIAxes,'ij')
            app.RodentTrackerTraceUIFigure.Visible ='on';
        end

        % Menu selected function: SaveasMenu
        function SaveasMenuSelected(app, event)
            app.Callingapp.ProgressText.Text = 'Saving Trace...';
            filter = {'*.jpg';'*.png'};
            [file,path] = uiputfile(filter);
            filename = fullfile(path,file);
            Trace_Image = getframe(app.UIAxes);
            Trace_Image = Trace_Image.cdata;
            imwrite(Trace_Image, filename);
            app.Callingapp.ProgressText.Text = 'Trace Saved';
        end
    end

    % App creation
    methods (Access = public)

        % Construct app
        function app = RodentTracker_Trace_Window(varargin)
            app = app@matlab.apps.App(varargin{:});

            if nargout == 0
                clear app
            end
        end
    end
end