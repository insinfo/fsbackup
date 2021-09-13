#define _CRT_SECURE_NO_WARNINGS
#define _CRT_NONSTDC_NO_DEPRECATE
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
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <io.h>
#include <time.h>
#include <chrono>

using std::chrono::high_resolution_clock;
using std::chrono::duration_cast;
using std::chrono::duration;
using std::chrono::milliseconds;

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
	//fprintf(stdout, " size %d --- \r\n", sizeof(buffer));
	nbytes = ssh_channel_read(channel, buffer, sizeof(buffer), 0);
	int count = 0;
	while (nbytes > 0)
	{

		auto fw = fwrite(buffer, 1, nbytes, stdout);
		//fprintf(stdout, " ----- %d --- %d --- \r\n", count, fw);
		if (fw != nbytes)
		{
			ssh_channel_close(channel);
			ssh_channel_free(channel);
			return NULL;
		}
		nbytes = ssh_channel_read(channel, buffer, sizeof(buffer), 0);
		count++;
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
//The example below shows how to open a connection to read a single file:
int scp_read(ssh_session session)
{
	ssh_scp scp;
	int rc;
	scp = ssh_scp_new(session, SSH_SCP_READ, "helloworld/helloworld.txt");
	if (scp == NULL)
	{
		fprintf(stderr, "Error allocating scp session: %s\n",
			ssh_get_error(session));
		return SSH_ERROR;
	}
	rc = ssh_scp_init(scp);
	if (rc != SSH_OK)
	{
		fprintf(stderr, "Error initializing scp session: %s\n",
			ssh_get_error(session));
		ssh_scp_free(scp);
		return rc;
	}

	ssh_scp_close(scp);
	ssh_scp_free(scp);
	return SSH_OK;
}


// Good chunk size
#define MAX_XFER_BUF_SIZE 16384
int sftpDownloadFileTo(ssh_session session, const char* fullRemotePath, const char* fullLocalPath)
{
	 
	int access_type;
	sftp_file file;
	char buffer[MAX_XFER_BUF_SIZE * 8];//128KB
	ssize_t nbytes, nwritten, rc;
	int fd;
	access_type = O_RDONLY;

	 sftp_session sftp = sftp_new(session);
	if (sftp == NULL)
	{
		fprintf(stderr, "Error allocating SFTP session: %s\n",
			ssh_get_error(session));
		return SSH_ERROR;
	}
	rc = sftp_init(sftp);
	if (rc != SSH_OK)
	{
		fprintf(stderr, "Error initializing SFTP session: %d.\n",
			sftp_get_error(sftp));
		sftp_free(sftp);
		return rc;
	}
		

	file = sftp_open(sftp, fullRemotePath, access_type, 0);

	if (file == NULL) {
		fprintf(stderr, "Can't open file for reading: %s\n", ssh_get_error(session));
		return SSH_ERROR;
	}

	fd = open(fullLocalPath, O_CREAT | O_RDWR, 0777);
	if (fd < 0) {
		fprintf(stderr, "Can't open file for writing: %s\n",
			strerror(errno));
		return SSH_ERROR;
	}

	for (;;) {
		nbytes = sftp_read(file, buffer, sizeof(buffer));
		if (nbytes == 0) {
			break; // EOF
		}
		else if (nbytes < 0) {
			fprintf(stderr, "Error while reading file: %s\n",
				ssh_get_error(session));
			sftp_close(file);
			return SSH_ERROR;
		}
		nwritten = write(fd, buffer, nbytes);
		if (nwritten != nbytes) {
			fprintf(stderr, "Error writing: %s\n",
				strerror(errno));
			sftp_close(file);
			return SSH_ERROR;
		}
	}
	rc = sftp_close(file);
	if (rc != SSH_OK) {
		fprintf(stderr, "Can't close the read file: %s\n",
			ssh_get_error(session));
		return rc;
	}

	sftp_free(sftp);
	return SSH_OK;
}

int main()
{
	//int access_type = O_WRONLY | O_CREAT | O_TRUNC;
	//fprintf(stdout, "access_type: %d\n", access_type);

	//auto teste = O_WRONLY;
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

	//string  resp = exec_ssh_command(my_ssh_session, "ls -l");
	//std::cout << resp << endl;
	clock_t tic = clock();
	auto t1 = high_resolution_clock::now();
	sftpDownloadFileTo(my_ssh_session, "/home/isaque.neves/go1.11.4.linux-amd64.tar.gz", "D:/MyDartProjects/fsbackup/libssh_binding/go1.11.4.linux-amd64.tar.gz");
	auto t2 = high_resolution_clock::now();
	clock_t toc = clock();
	
	duration<double, std::milli> ms_double = t2 - t1;	
	std::cout << ms_double.count() << " ms\r\n";

	printf("Elapsed: %f seconds\n", (double)(toc - tic) / CLOCKS_PER_SEC);

	ssh_disconnect(my_ssh_session);
	ssh_free(my_ssh_session);

	std::cout << "End\n";

	return 0;
}

