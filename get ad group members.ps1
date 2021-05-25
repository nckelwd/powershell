Get-ADgroupmember -identity “” | get-aduser -property displayname, mail | select name, displayname, samaccountname, mail 



git config --global user.email "elwoodn@me.com"
git config --global user.name "Nick Elwood"