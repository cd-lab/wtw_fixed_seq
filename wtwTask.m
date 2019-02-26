function [] = wtwTask()
% presents the wtw experiment

try
    
    % skipping sync tests
    % Screen('Preference', 'SkipSyncTests', 1);
    % relax sync tests, allow SD of 3 ms rather than 1 ms
    Screen('Preference','SyncTestSettings',0.003);
    
    %%% modifiable parameters
    % timing
    sessMins = 0.5; % block duration in minutes: normally 15
    display.iti = 2; % intertrial interval in sec
    % payoff contingencies
    params.currency = 'money'; % set to 'money' or 'points'
    params.payoffHi = 10; % cents
    params.payoffLo = 0; % cents
    % response key (only one required)
    params.respChar = {'space'};
    % token colors
    % this order is also fixed. If order of timing conditions is switched,
    % order of colors should be left the same. 
    blockTokenColor = {'green', 'purple'};
    
    %%% special display prefs if on windows OS
    if IsWin
        % modify text display settings
        % set font to helvetica (default is courier new)
        Screen('Preference', 'DefaultFontName', 'Helvetica');
        % set style to normal (=0) (default is bold [=1])
        Screen('Preference', 'DefaultFontStyle', 0);
    end
    
    % set path
    path(path,'stimSubFx');
    
    % name datafile
    cbal = 1; % all subjects receive the same block order
    [dataFileName,dataHeader] = gatherSubInfo('wtw-timing', 1, '', cbal);
    params.datafid = fopen([dataFileName,'.txt'],'w');
    params.pracfid = fopen([dataFileName,'_prac.txt'],'w');
    
    % set parameters for the block order
    % (timing distributions are defined in drawSample.m)
    timingDistribs = {'logspace_1.75_32', 'unif16'};
    trialsFx = {@showTrials, @showTrials};
    
    % open the screen
    bkgd = 80; % set shade of gray for screen background
    [wid,origin,dataHeader] = manageExpt('open',dataHeader,bkgd); % standard initial tasks
    
    % write a file with header data
    hdr_fid = fopen([dataFileName,'_hdr.txt'],'w');
    fprintf(hdr_fid,'ID: %s\n',dataHeader.id);
    fprintf(hdr_fid,'cbal: %s\n',num2str(dataHeader.cbal));
    fprintf(hdr_fid,'bk1 distrib: %s\n',timingDistribs{1});
    fprintf(hdr_fid,'bk2 distrib: %s\n',timingDistribs{2});
    fprintf(hdr_fid,'bk1 trial function: %s\n',func2str(trialsFx{1}));
    fprintf(hdr_fid,'bk2 trial function: %s\n',func2str(trialsFx{1}));
    fprintf(hdr_fid,'randSeed: %16.16f\n',dataHeader.randSeed);
    fprintf(hdr_fid,'sessionTime: %s\n',num2str(dataHeader.sessionTime));
    fclose(hdr_fid);
    
    % set screen locations for stimuli and buttons
    rects = setRects(origin,wid,params);
    
    % initialize display
    HideCursor;
    params.wid = wid;
    params.bkgd = bkgd;
    display.totalWon = 0; % initial value
    display.currency = params.currency; 
    params.sessSecs = sessMins * 60;
    
    % colors to be used
    % tokColors.prac = [0, 0, 0];
    tokColors.green = 50+[0, 100, 0];
    tokColors.purple = 50+[80, 0, 100];
    
    % initialize data logging structure
    dataHeader.distribs = timingDistribs; % log this subject's timing distribution
    trialData = struct([]);
    params.datarow = 0;
    
    % present individual blocks
    nBks = length(trialsFx); % number of blocks to present
    for bkIdx = 1:nBks
    
        % set block-specific parameters
        params.bkIdx = bkIdx;
        params.distrib = timingDistribs{bkIdx};
        display.tokenColor = tokColors.(blockTokenColor{bkIdx});
        
        % show instructions
        if bkIdx == 1
            instrucBlock(params,rects,display,sessMins,nBks,bkIdx);
        end
            
        % show the trials
        params.trialLimit = inf;
        [trialData, params, display] = trialsFx{bkIdx}(params,rects,display,trialData);
        
        % save data
        save(dataFileName,'dataHeader','trialData');
        
        % intermediate instructions screen
        % (shown after the non-final block[s])
        if bkIdx<nBks
            Screen('TextSize',wid,rects.txtsize_msg);
            msg = sprintf('Block %d complete.\n\nIn the next block, the timing and structure of the task may change.\n\nPress the spacebar to begin block %d.', bkIdx, bkIdx+1);
            showMsg(wid,bkgd,msg);
        end
        
    end % loop over blocks   
    
    % show the final screen
    switch params.currency
        case 'money', earningsStr = sprintf('Total earned: $%2.2f.',display.totalWon/100);
        case 'points', earningsStr = sprintf('Total earned: %d points.',display.totalWon);
    end
    Screen('TextSize',wid,rects.txtsize_msg);
    msg = sprintf('Complete!\n%s',earningsStr);
    showMsg(wid,bkgd,msg,'q');
    
    % close the expt
    manageExpt('close'); % note: this closes any text files open for writing
    
    % print some information
    fprintf('\n\nParticipant: %s\n',dataHeader.dfname);
    fprintf('%s\n\n',earningsStr);
    
catch ME
    
    % close the expt
    disp(getReport(ME));
    fclose('all');
    manageExpt('close');
    
end % try/catch loop

    

    


