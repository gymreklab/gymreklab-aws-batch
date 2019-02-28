FROM gymreklab/str-toolkit

# Install aspera for fast file transfer
RUN mkdir /aspera
RUN wget http://download.asperasoft.com/download/sw/connect/3.6.2/aspera-connect-3.6.2.117442-linux-64.tar.gz -P /aspera/
RUN tar -xvzf /aspera/aspera-connect-3.6.2.117442-linux-64.tar.gz -C /aspera/
RUN useradd -m aspera
RUN usermod -L aspera
RUN runuser -l aspera -c '/aspera/aspera-connect-3.6.2.117442-linux-64.sh'
RUN ln -s /home/aspera/.aspera/connect/bin/ascp /usr/local/bin

# Add the fetch_and_run.sh script
ADD fetch_and_run.sh /usr/local/bin/fetch_and_run.sh

# Get set up to run
WORKDIR /tmp
ENTRYPOINT ["/usr/local/bin/fetch_and_run.sh"]
