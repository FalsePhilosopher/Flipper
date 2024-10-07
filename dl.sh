#!/bin/bash
SHA256='4f07311951cb281362c57583e9fff62d67d84a89'
Link='https://github.com/FalsePhilosopher/Flipper/releases/latest/download/Flipper.tar.zst'
obtainium() {
  if ! command -v gh &> /dev/null; then
    echo "GitHub CLI not found. Checking aria2c..."
    if ! command -v aria2c &> /dev/null; then
      echo "aria2c could not be found. Please install either GitHub CLI or aria2c." && sleep 20
      exit 1
    else
      echo "Using aria2c to download..."
      aria2c --checksum=sha-256=$SHA256 $Link
    fi
  else
    echo "Using GitHub CLI to download..."
    gh release download -p 'Flipper.tar.*' -R FalsePhilosopher/Flipper
  fi
}
check() {
  if ! command -v b3sum &> /dev/null; then
    echo "b3sum not found. Checking sha256sum"
    if ! command -v sha256sum &> /dev/null; then
      echo "sha256sum could not be found. Please install b3sum or sha256sum." && sleep 20
      exit 1
    else
      echo "Using sha256sum for verification"
      sha256sum -c SHA256
      echo "There will be a single hash check error as there are two different hash files included for windows compatibility and one will throw an error for the other, so if there is a single hash error then it was successful."
    fi
  else
    echo "Using b3sum for verification"
    b3sum -c B3.SUM
    echo "There will be a single hash check error as there are two different hash files included for windows compatibility and one will throw an error for the other, so if there is a single hash error then it was successful."
  fi
}
if ! command -v zstd &> /dev/null
then
    echo "zstd could not be found, please install it." && sleep 20
    exit 1
fi

cd /tmp/ || { echo "Failed to change directory to /tmp/"; exit 1; }
obtainium
echo "Extracting Flipper.tar.zst"
if tar --use-compress-program="zstd -d -T0" -xvf "Flipper.tar.zst" --directory "$HOME/Downloads"; then
  echo "Successfully extracted Flipper.tar.zst"
  rm "Flipper.tar.zst"
else
  echo "Failed to extract Flipper.tar.zst" && exit 1
fi

cd "$HOME/Downloads/Flipper/" || { echo "Failed to change to Flipper directory"; exit 1; }
check
echo "extracting BadUSB.tar.zst"
if tar --use-compress-program="zstd -d -T0" -xvf "BadUSB.tar.zst"; then
  echo "Successfully extracted BadUSB.tar.zst"
  rm "BadUSB.tar.zst"
else
  echo "Failed to extract BadUSB.tar.zst" && exit 1
fi
cd BadUSB || { echo "Failed to change to BadUSB directory"; exit 1; }
check
echo "All done"
