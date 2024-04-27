# Инструкция по сборке

Возникла задача реализации C++ inference для yolo8 через OpenCV DNN. Для этого потребовалось собрать OpenCV c поддержкой CUDA. Оказалось, что 4.9.0 версия OpenCV собирается но не работает с yolo8. Также по отзывам 4.8.0 (сам не проверял). С версией 4.7.0 все работает, но при сборке с новой cuda12 возникают ошибки. К счастью удалось найти решение проблемы.

## Настройка окружения

Необходимо сперва установить cuda12

    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb
    sudo dpkg -i cuda-keyring_1.1-1_all.deb
    sudo apt update
    sudo apt install cuda-toolkit
    sudo apt install cuda

Теперь надо настроить пути (написано для версии 12.3)

    export PATH=/usr/local/cuda-12.3/bin${PATH:+:${PATH}}
    export LD_LIBRARY_PATH=/usr/local/cuda-12.3/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
    source ~/.bashrc

А теперь cudnn8 (с 9 на данный момент не собирается)

    sudo apt install libcudnn8
    sudo apt install libcudnn8-dev
    sudo apt install libcudnn8-samples

## Сборка

Пакеты с "cud" в названии:

```
cudaarithm
cudabgsegm
cudacodec
cudafeatures2d
cudafilters
cudaimgproc
cudalegacy
cudaobjdetect
cudaoptflow
cudastereo
cudawarping
cudev
```

Внутри папки opencv-4.7.0

    mkdir build
    cd build
    cmake -DBUILD_EXAMPLES=ON -DWITH_CUDA=ON -DWITH_CUDNN=ON -DOPENCV_DNN_CUDA=ON .. -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules/cudev\;../../opencv_contrib/modules/cudaarithm\;../../opencv_contrib/modules/cudaimgproc\;../../opencv_contrib/modules/cudawarping
    make -j$(nproc)

Установка в систему

    sudo make install

## Как получен этот репозиторий

- Берем релиз OpenCV 4.7.0 с официального сайт
- Берем также opencv_contrib там же, переключаемся на ревизию 4.7.0: git checkout 4.7.0
- Вносим исправления в соответствии со следующей [рекомендацией](https://github.com/opencv/opencv/issues/23893)

```
Disclaimer:
I have very limited knowledge of the OpenCV source code, so if you follow my "solution", do it at your own risk.

Solution:
I "solved" this by using static_cast.

You want to change line 114 in opencv/modules/dnn/src/cuda4dnn/primitives/normalize_bbox.hpp:
from:
if (weight != 1.0)
to:
if (weight != static_cast<T>(1.0))

As well as line 124 in opencv/modules/dnn/src/cuda4dnn/primitives/region.hpp (due to a similar error):
from:
if (nms_iou_threshold > 0) {
to:
if (nms_iou_threshold > static_cast<T>(0)) {

Explanation:
Since both variables, weight and nms_iou_threshold, are templated and finally boil down to a primitive type during compilation, it is meaningful to use a static_cast to convert the respective constant (1.0 (by default double) and 0 (by default int)) to the template type. Based on the operator candidates the required types should all be compatible, i.e., the constant values are safe to be casted to the target template type.

```

