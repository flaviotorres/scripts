import os, time, sys, telnetlib, getpass, commands

# 'HeartBeat' Hibrido, pode ser usado para monitorar servicos em Linux, Windows e Solaris
# Flavio Torres, ftorres@ymail.com
# Outubro, 2009

# Servidor a ser monitorado. 
MASTER = {"IP":"10.1.1.7", "SO":"Linux"}
SLAVE = {"IP":"10.1.1.4", "SO":"Linux"}

# Servico(s) a ser(em) monitorado(s)
# Ex: SERVICEPORTS = [80, 22, 25,]
SERVICEPORTS = [80, 21]

# Nome dos servicos (daemon) a serem monitorados e iniciados
# Os nomes devem ser respectivos a porta informada no vetor SERVICEPORTS acima
# Ex: SERVICENAMES = {80:'httpd',22:'ssh',25:'postfix',}
# Este nome deve ser correspondente ao daemon/servico a ser iniciado
# Ex:.... (escrever) - iisadmin/W3SVC
SERVICENAMES = {80:'apache2', 21:'vsftpd',}

# Tempo em segundos para realizar a checagem do servico
TEMPO = 5

# Rede virtual utilizada no servico de alta disponibilidade
REDEHA = {"IP":"10.1.1.10", "MASK":"255.0.0.0", "GW":"10.1.1.1"}

# Funcao LOG

class AutoFlush:
	def __init__(self, stream):
		self.stream = stream
	def write(self, text):
		self.stream.write(text)
		self.stream.flush()

flog=open('Monitoramento.log','a')
flog=AutoFlush(flog)


def Mail():
	import smtplib
	from email.MIMEMultipart import MIMEMultipart
	from email.MIMEBase import MIMEBase
	from email.MIMEText import MIMEText
	from email import Encoders
	import os

	gmail_user = "torresflavio@gmail.com"
	gmail_pwd = "23645"

	def mail(to, subject, text, attach):
		msg = MIMEMultipart()
		
		msg['From'] = gmail_user
		msg['To'] = to
		msg['Subject'] = subject
		
		msg.attach(MIMEText(text))
	
		part = MIMEBase('application', 'octet-stream')
		part.set_payload(open(attach, 'rb').read())
		Encoders.encode_base64(part)
		part.add_header('Content-Disposition','attachment; filename="%s"' % os.path.basename(attach))
		msg.attach(part)
		
		mailServer = smtplib.SMTP("smtp.gmail.com", 587)
		mailServer.ehlo()
		mailServer.starttls()
		mailServer.ehlo()
		mailServer.login(gmail_user, gmail_pwd)
		mailServer.sendmail(gmail_user, to, msg.as_string())
		# Should be mailServer.quit(), but that crashes...
		mailServer.close()
	
		mail("torresflavio@gmail.com",
		"Monitoramento - Falha em servidor",
		"Foi encontrado um erro no servidor MASTER",
		"Monitoramento.log")


def cMasterLin():
	# Funcao que realiza a conexao com o servidor Master LINUX
	# - conecta e desconfigura a rede HA
	#**********************************************************
	try:
		ETH=os.popen('''ssh %s "/sbin/ifconfig | /bin/grep %s -B 1| sed '2d;s/ .*//g'"''' % (MASTER["IP"],REDEHA["IP"])).read()
		os.system('''ssh %s "/sbin/ifconfig %s down"''' % (MASTER["IP"], ETH.replace("\n","")))
	except:
		print "[ERRO] Falha SSH - desconfiguracao da rede linux"
	
def cMasterWin():
	try:
		os.system('''ssh %s netsh interface ip delete address "LAN" addr=%s''' % (MASTER["IP"],REDEHA["IP"]))
	except:
		print "[ERRO] Falha SSH - desconfiguracao da rede windows"

def iServicosLinux():
	# Inicia os servicos no Slave Linux
	for SERVICO in SERVICENAMES:
		try:
			os.system('''/etc/init.d/%s start''' % (SERVICENAMES[SERVICO]))
		except:
			print "[ERRO] Falha ao iniciar o servico %s",SERVICO,""


def iServicosWindows():
	# inicia os servicos no Slave Windows - localmente
	for SERVICO in SERVICENAMES:
		try:
			os.system('''net start %s''' % (SERVICENAMES[SERVICO]))
		except:
			print "[ERRO] Falha ao iniciar o servico %s",SERVICO,""

def sRedeLin():
	# Inicia rede no Slave Linux - Localmente
	try:
		os.system('''ifconfig eth0:1 %s netmask %s up''' % (REDEHA["IP"], REDEHA["MASK"]))
	except:
		print "[ERRO] Houve falha na configuracao da rede - Slave Linux"

def sRedeWin():
	# Inicia rede no Slave Windows - Localmente
	try:
		os.system('''netsh interface ip add address name="LAN" addr=%s mask=%s''' % (REDEHA["IP"], REDEHA["MASK"]))
	except:
		print "[ERRO] Houve falha na configuracao da rede - Windows"

def cMasterRede():
	if MASTER["SO"] == "Linux":
		# Master = Linux - Conectar no Master Linux
		print "Chama funcao cMasterLin - Conecta no master linux para baixar a rede"
		cMasterLin()

	else:
		# Master = Windows - Conectar no Master Windows
		print "Chama funcao cMasterWin - Conecta no master windows para baixar a rede"
		cMasterWin()

    
def Monitora():
	
	FLAG = 2

	while FLAG > 1:
		for PORTA in SERVICEPORTS:
			try:
				con = telnetlib.Telnet(MASTER["IP"], PORTA)
				con.write("exit\n")
				# print con.read_all()
				print "Conexao em",MASTER["IP"],"na porta",PORTA,"- [OK]", SERVICENAMES[PORTA],"."
			except:
				print "\n",time.ctime(),"Houve erro na conexao no servidor",MASTER["IP"],"na porta",PORTA,"servico",SERVICENAMES[PORTA],""
				print >>flog,"\n",time.ctime(),"Houve erro na conexao no servidor",MASTER["IP"],"na porta",PORTA,"servico",SERVICENAMES[PORTA],""
 
				if SLAVE["SO"] == "Linux":
					# *** LINUX ****
					# **************
					# Sobre os servicos no server Linux
					print "Chama funcao iServicosLinux - inicia os servicos no linux slave", PORTA,""
					iServicosLinux()
					
				    	# Devemos conectar no master para baixar a rede
					print "Chama funcao - Conecta no master e baixa a rede - Linux"
					cMasterRede()

					# Inicia rede slave - Linux
					print "Chama a funcao sRedeLin - inicia rede HA no linux"
					sRedeLin()
				else:
					# *** WINDOWS ***
					# ***************
					# Sobe servicos
			    		print "Chama funcao iServicosWindows - iniciar os servicos no windows slave"
					iServicosWindows()
					# Devemos conectar no master para baixar a rede
					print "Chama funcao - Conecta no master e baixa a rede - Windows"
					cMasterRede()
					
					# Inicia rede no slave Windows
					print "Chama funcao sRedeWin - Inicia rede HA no windows"
					sRedeWin()

				FLAG = 0
				Mail()
				break
			
		time.sleep(TEMPO)

Monitora()
