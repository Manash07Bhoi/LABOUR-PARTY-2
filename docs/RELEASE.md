# Release Process & Signing Configuration

This document outlines the standard procedure for signing and releasing the Labour Party application.

## 1. Keystore Generation
The project requires a production-grade keystore for release builds. You should not use the debug keys. If you do not have the keystore yet, generate one using the following command (recommended properties: RSA, 2048+ keysize, long validity):

```bash
keytool -genkey -v \
-keystore android/upload-keystore.jks \
-keyalg RSA \
-keysize 2048 \
-validity 10000 \
-alias labourparty
```

**Security Note:** Keep your keystore and its passwords secure. Never commit the `upload-keystore.jks` or `.properties` files containing secrets to version control.

## 2. Release Configuration
The build process expects a `key.properties` file located at `android/key.properties`. A template is provided at `android/key.properties.example`.

Create `android/key.properties` with the following keys, replacing the values with your keystore credentials:

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=labourparty
storeFile=upload-keystore.jks
```

If the release signing configuration is missing, running a release build will fail with a clear message:
`Release signing configuration missing.`

## 3. Building for Release

Once the `key.properties` file is configured correctly, use the standard Flutter build commands to generate the release artifacts:

```bash
flutter build apk --release
flutter build appbundle
```

## 4. Release Validation Checklist
Before distributing the application, verify the following:

- [ ] Debug build succeeds (`flutter build apk --debug`)
- [ ] Signed APK builds correctly (`flutter build apk --release`)
- [ ] Signed AAB builds correctly (`flutter build appbundle`)
- [ ] Application installs successfully from the signed APK
- [ ] Application upgrades properly over a previous installation
- [ ] Application icon and splash screen are correct
- [ ] Release metadata (version code, version name) is accurate
