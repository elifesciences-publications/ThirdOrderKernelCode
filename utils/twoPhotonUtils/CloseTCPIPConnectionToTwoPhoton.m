function CloseTCPIPConnectionToTwoPhoton(connectionToTwoPhoton)

fwrite(connectionToTwoPhoton, 'end')
fclose(connectionToTwoPhoton);
delete(connectionToTwoPhoton);