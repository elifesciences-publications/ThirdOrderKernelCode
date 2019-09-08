function SendNotification(Q)


if Q.sendEmail
    % Modify these two lines to reflect
    % your account and password.
    
    myaddress = 'drosophila.rig1@gmail.com';
    mypassword = 'jointhelab1';
    
    setpref('Internet','E_mail',myaddress);
    setpref('Internet','SMTP_Server','smtp.gmail.com');
    setpref('Internet','SMTP_Username',myaddress);
    setpref('Internet','SMTP_Password',mypassword);
    
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', ...
        'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
    
    if isfield(Q, 'messageToSend')
        sendmail(Q.emailAddress, '', Q.messageToSend);
        
    else
        sendmail(Q.emailAddress, '', 'Run''s finished!');
    end
end
end
