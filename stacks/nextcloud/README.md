# Nextcloud

The stack uses the fpm version of nextcloud which relies on an external web server to serve files, and will create php processes as needed.
Nginx is the reverse proxy used here, and it must have a configuration file set up.
An example file is provided in the `examples` folder and must be mounted to the nginx container.

## PocketID
Nextcloud may integrate with pocketid through an external plugin with directions provided [here](https://pocket-id.org/docs/client-examples/nextcloud).
After editing the config.php file in the config folder, make sure the file is still owned by either user & group 33 or www-data. If it is not, run the command `chown 33:33 config.php`.

## S3
The provided configuration is designed to work with the `garage` stack and is quite simple to setup. 
1. Navigate to garage's webui using the address https://g.your_domain .
2. Create a user with a key and save the access and secret key.
3. Create a nextcloud bucket in the garage webui.
4. Under permissions, click allow key and give full permissions to your nextcloud key.
5. Generate a secure encryption key for nextcloud to use. 
This [website](https://it-tools.tech/token-generator) provides a secure,client-side token generator.
Remember that some symbols can intefere with yaml variable interpolation.
I recommend avoid the symbols and generating a 64 character long string of just numbers and upper/lower case characters.
6. Populate the environment variables in this stack with your values.
 - s3_access_key=`access_key from step 2`
 - s3_enc_key=`key from step 5`
 - s3_secret_key=`secret_key from step 2`

## Permissions
Nextcloud will only function if the files are owned by a user and group with the id `33`. This is often present on many distributions as
`www-data` but not always. In any case, ensure that nextcloud's data folder is owned by this user. This includes checking after making
changes to the config.php file as it may change ownership. Use the command `chown -R 33:33 app` in your chosen $data directory to fix
ownership problems.

## Post-install
Nextcloud uses both declarative environment variables and a `config.php` file to provide settings.
One change that should be made is to tell nextcloud to use our dedicated image service imaginary.
Include these lines in the `config.php` file:
```php
<?php
$CONFIG = array (
  // other settings
  'preview_imaginary_url' => 'http://nextcloud_imaginary:9000',
  'enabledPreviewProviders' => 
  array (
    0 => 'OC\\Preview\\Imaginary',
  ),
);
```
