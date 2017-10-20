FROM php:7.1-apache
# Customize container to match Drupal 8 requirements
RUN a2enmod rewrite
RUN apt-get update -y && apt-get install -y libpng-dev zip unzip mysql-client ssmtp mailutils libfreetype6-dev libjpeg62-turbo-dev
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install gd opcache pdo pdo_mysql zip bcmath exif
RUN pecl install apcu && echo extension=apcu.so > /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini
# Configure sendmail
RUN echo "hostname=localhost.localdomain" > /etc/ssmtp/ssmtp.conf
RUN echo "mailhub=mailhog:1025" >> /etc/ssmtp/ssmtp.conf
# Install Drush Launcher
RUN curl -OL https://github.com/drush-ops/drush-launcher/releases/download/0.4.2/drush.phar && \
  chmod +x drush.phar && \
  mv drush.phar /usr/local/bin/drush
# Add our custom configuration
COPY php.ini /usr/local/etc/php/
COPY apache2.conf /etc/apache2/custom.conf
RUN echo "Include custom.conf" >> /etc/apache2/apache2.conf
# Use a custom docroot
ENV APACHE_DOCUMENT_ROOT /var/www/html/docroot
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
