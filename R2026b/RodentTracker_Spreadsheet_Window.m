classdef RodentTracker_Spreadsheet_Window < matlab.apps.App

    % Used to locate and load the app's XML configuration file
    properties (Access = public, Constant)
        AppConfigFilename = './RodentTracker_Spreadsheet_Window.xml'; % File path to the app configuration file containing component layout and settings
    end

    % Properties that correspond to app components
    properties (Access = public)
        RodentTrackerSpreadsheetUIFigure  matlab.ui.Figure
        FileMenu                        matlab.ui.container.Menu
        SaveasMenu                      matlab.ui.container.Menu
        AnalyzeMenu                     matlab.ui.container.Menu
        SAPMenu                         matlab.ui.container.Menu
        UITable                         matlab.ui.control.Table
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
            app.RodentTrackerSpreadsheetUIFigure.Units = 'normalized';
            app.RodentTrackerSpreadsheetUIFigure.Position = [0.9426-0.47*(yres/xres) 0.06 0.47*(yres/xres) 0.42];
            app.RodentTrackerSpreadsheetUIFigure.Units = 'pixels';
            app.RodentTrackerSpreadsheetUIFigure.Visible = 'off';

            app.Callingapp = Mainapp;
        end

        % Menu selected function: SaveasMenu
        function SaveasMenuSelected(app, event)
            app.Callingapp.ProgressText.Text = 'Saving Spreadsheet...';
            filter = {'*.mat';'*.xls';'*.xlsx';'*.csv'};
            [file,path] = uiputfile(filter);
            filename = fullfile(path,file);
            [~,~,ext] = fileparts(filename);
            t = app.RodentTrackerSpreadsheetUIFigure.Children(1).Data;
            if strcmp(ext,'.mat')
                save(filename,'t')
            else
                writetable(t,filename);
            end
            app.Callingapp.ProgressText.Text = 'Spreadsheet Saved';
        end

        % Close request function: RodentTrackerSpreadsheetUIFigure
        function RodentTrackerSpreadsheetUIFigureCloseRequest(app, event)
            app.RodentTrackerSpreadsheetUIFigure.Visible ="off";
            app.Callingapp.MainSpreadsheetMenu.Checked = "off";
        end

        % Menu selected function: SAPMenu
        function SAPMenuSelected(app, event)
            app.Callingapp.SAP_Window.RodentTrackerSAPDetectionUIFigure.Visible = "on";

            if app.Callingapp.SAP_Window.RodentTrackerSAPDetectionUIFigure.Visible == "on" 
                app.Callingapp.SAP_Window.RodentTrackerSAPDetectionUIFigure.Visible = "off";
                app.SAPMenu.Checked = "off";
                app.Callingapp.SAPMenu.Checked = "off";
            else
                app.Callingapp.SAP_Window.RodentTrackerSAPDetectionUIFigure.Visible = "on";
                app.SAPMenu.Checked = "on";
                app.Callingapp.SAPMenu.Checked = "on";
                figure(app.Callingapp.SAP_Window.RodentTrackerSAPDetectionUIFigure)
            end
        end
    end

    % App creation
    methods (Access = public)

        % Construct app
        function app = RodentTracker_Spreadsheet_Window(varargin)
            app = app@matlab.apps.App(varargin{:});

            if nargout == 0
                clear app
            end
        end
    end
end