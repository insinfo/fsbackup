
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <stdexcept>
#include <string.h>
#include <exception>
#include <fstream>
#include <libssh/callbacks.h>
#include <libssh/libssh.h>
#include <libssh/sftp.h>
#include "custom_exception.cpp"

//using namespace std;
using std::string;
using std::cout;
using std::endl;
using std::cin;



string exec_ssh_command(ssh_session
	session, const char* command) {
	string receive = "";
	int rc, nbytes;
	char buffer[256];
	ssh_channel channel = ssh_channel_new(session);
	if (channel == NULL)
		return NULL;

	rc = ssh_channel_open_session(channel);
	if (rc != SSH_OK) {
		ssh_channel_free(channel);
		return NULL;
	}

	rc = ssh_channel_request_exec(channel, command);
	if (rc != SSH_OK) {
		ssh_channel_close(channel);
		ssh_channel_free(channel);		
		return NULL;
	}
	nbytes = ssh_channel_read(channel, buffer, sizeof(buffer), 0);
	while (nbytes > 0)
	{
		if (fwrite(buffer, 1, nbytes, stdout) != nbytes)
		{
			ssh_channel_close(channel);
			ssh_channel_free(channel);
			return NULL;
		}
		nbytes = ssh_channel_read(channel, buffer, sizeof(buffer), 0);
	}

	if (nbytes < 0)
	{
		ssh_channel_close(channel);
		ssh_channel_free(channel);
		return NULL;
	}

	ssh_channel_send_eof(channel);
	ssh_channel_close(channel);
	ssh_channel_free(channel);

	return receive;
}

int main()
{
	ssh_session my_ssh_session;
	int rc;
	int port = 22;
	string password = "Ins257257";
	auto host = "192.168.133.13";
	auto username = "isaque.neves";

	int verbosity = SSH_LOG_PROTOCOL;
	// Abra a sessão e defina as opções
	my_ssh_session = ssh_new();
	if (my_ssh_session == NULL)
		exit(-1);
	ssh_options_set(my_ssh_session, SSH_OPTIONS_HOST, host);
	//ssh_options_set(my_ssh_session, SSH_OPTIONS_LOG_VERBOSITY, &verbosity);
	ssh_options_set(my_ssh_session, SSH_OPTIONS_PORT, &port);
	// Conecte-se ao servidor
	rc = ssh_connect(my_ssh_session);
	if (rc != SSH_OK)
	{
		//sprintf(dest, "%s%s", one, two)
		fprintf(stderr, "Error connecting to host: %s\n",
			ssh_get_error(my_ssh_session));
		exit(-1);
		//throw new CustomException(std::string("Error connecting to host: %s\n") + ssh_get_error(my_ssh_session));
	}
	// Autenticar-se

	rc = ssh_userauth_password(my_ssh_session, username, password.c_str());
	if (rc != SSH_AUTH_SUCCESS)
	{
		fprintf(stderr, "Error authenticating with password: %s\n",
			ssh_get_error(my_ssh_session));
		ssh_disconnect(my_ssh_session);
		ssh_free(my_ssh_session);
		exit(-1);
	}

	string  resp = exec_ssh_command(my_ssh_session,"ls -l");
	std::cout << resp << endl;

	ssh_disconnect(my_ssh_session);
	ssh_free(my_ssh_session);

	std::cout << "Fim\n";

	return 0;
}

