% convert mat date to string date
% csvwrite("/D/MIT-WHOI/github_repos/plankton-index/data/manual_mat_date.csv",datevec(datestr(matdate)))
% 
% csvwrite("/D/MIT-WHOI/github_repos/plankton-index/data/classcount.csv",classcount)
% 



% converting class2use to csv file
% T = cell2table(class2use(:,:))
 
% Write the table to a CSV file
% writetable(T,"/D/MIT-WHOI/github_repos/plankton-index/data/class2use.csv")

% csvwrite("/D/MIT-WHOI/github_repos/plankton-index/data/ml_analyzed_mat.csv",ml_analyzed_mat)



%F = cell2table(filelist(:,:))
 
% Write the table to a CSV file
%writetable(F,"/D/MIT-WHOI/github_repos/plankton-index/data/filelist.csv")

man = cell2table(manual_list(2:end,1:2))
writetable(man,"/D/MIT-WHOI/github_repos/plankton-index/data/manual_list.csv",'WriteVariableNames',0)

