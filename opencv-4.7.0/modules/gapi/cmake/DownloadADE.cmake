set(ade_src_dir "${OpenCV_BINARY_DIR}/3rdparty/ade")
set(ade_filename "v0.1.2a.zip")
set(ade_subdir "ade-0.1.2a")
set(ade_md5 "fa4b3e25167319cb0fa9432ef8281945")
ocv_download(FILENAME ${ade_filename}
             HASH ${ade_md5}
             URL
               "${OPENCV_ADE_URL}"
               "$ENV{OPENCV_ADE_URL}"
               "file:///${CMAKE_BINARY_DIR}/../../"
             DESTINATION_DIR ${ade_src_dir}
             ID ADE
             STATUS res
             UNPACK RELATIVE_URL)

if (NOT res)
    return()
endif()

set(ADE_root "${ade_src_dir}/${ade_subdir}/sources/ade")
file(GLOB_RECURSE ADE_sources "${ADE_root}/source/*.cpp")
file(GLOB_RECURSE ADE_include "${ADE_root}/include/ade/*.hpp")
add_library(ade STATIC ${OPENCV_3RDPARTY_EXCLUDE_FROM_ALL}
    ${ADE_include}
    ${ADE_sources}
)
target_include_directories(ade PUBLIC $<BUILD_INTERFACE:${ADE_root}/include>)
set_target_properties(ade PROPERTIES
  POSITION_INDEPENDENT_CODE True
  OUTPUT_NAME ade
  DEBUG_POSTFIX "${OPENCV_DEBUG_POSTFIX}"
  COMPILE_PDB_NAME ade
  COMPILE_PDB_NAME_DEBUG "ade${OPENCV_DEBUG_POSTFIX}"
  ARCHIVE_OUTPUT_DIRECTORY ${3P_LIBRARY_OUTPUT_PATH}
)

if(ENABLE_SOLUTION_FOLDERS)
  set_target_properties(ade PROPERTIES FOLDER "3rdparty")
endif()

if(NOT BUILD_SHARED_LIBS)
  ocv_install_target(ade EXPORT OpenCVModules ARCHIVE DESTINATION ${OPENCV_3P_LIB_INSTALL_PATH} COMPONENT dev OPTIONAL)
endif()

ocv_install_3rdparty_licenses(ade "${ade_src_dir}/${ade_subdir}/LICENSE")
