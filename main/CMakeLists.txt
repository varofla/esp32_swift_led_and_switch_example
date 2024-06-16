# ESP-IDF 컴포넌트 등록
idf_component_register(
  SRCS "Dummy.c"
  INCLUDE_DIRS "."
)

# Swift Path 검색
execute_process(COMMAND xcrun -f swiftc OUTPUT_VARIABLE SWIFTC OUTPUT_STRIP_TRAILING_WHITESPACE)

# Swift 코드 빌드를 위해 툴체인 사용
add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/_swiftcode.o
  COMMAND
  ${SWIFTC}
  -target riscv32-none-none-eabi
  -Xfrontend -function-sections -enable-experimental-feature Embedded -wmo -parse-as-library -Osize
  $$\( echo '$<TARGET_PROPERTY:__idf_main,INCLUDE_DIRECTORIES>' | tr '\;' '\\n' | sed -e 's/\\\(.*\\\)/-Xcc -I\\1/g' \)
  $$\( echo '${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES}' | tr ' ' '\\n' | sed -e 's/\\\(.*\\\)/-Xcc -I\\1/g' \)
  -import-bridging-header ${CMAKE_CURRENT_LIST_DIR}/BridgingHeader.h
  ${CMAKE_CURRENT_LIST_DIR}/Main.swift
  -c -o ${CMAKE_CURRENT_BINARY_DIR}/_swiftcode.o
  DEPENDS
  ${CMAKE_CURRENT_LIST_DIR}/BridgingHeader.h
  ${CMAKE_CURRENT_LIST_DIR}/Main.swift
)
add_custom_target(main-swiftcode DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/_swiftcode.o)

# Swift 빌드 결과물 링크
target_link_libraries(__idf_main
  ${CMAKE_CURRENT_BINARY_DIR}/_swiftcode.o
)
add_dependencies(__idf_main main-swiftcode)
