// RUN: tac-opt-all-backends -tfl-tac-filter='use-test-setting=true' %s -split-input-file -verify-diagnostics | FileCheck %s

// CHECK-LABEL: testFunctionSkiped
func.func @testFunctionSkiped(%arg0: tensor<1xf32>, %arg1: tensor<1xf32>) {
  // CHECK: tfl.add
  // CHECK-SAME: tac.skip_target_annotation
  %0 = "tfl.add"(%arg0, %arg1) {fused_activation_function = "RELU6"} : (tensor<1xf32>, tensor<1xf32>) -> tensor<1xf32>
  // CHECK: tfl.add
  // CHECK-SAME: tac.skip_target_annotation
  %1 = "tfl.add"(%arg0, %0) {fused_activation_function = "RELU"} : (tensor<1xf32>, tensor<1xf32>) -> tensor<1xf32>
  // CHECK: tfl.relu
  // CHECK-SAME: tac.skip_target_annotation
  %2 = "tfl.relu"(%arg0) : (tensor<1xf32>) -> tensor<1xf32>
  func.return
}

// CHECK-LABEL: testFunctionInclude
// CHECK-NOT: tac.skip_target_annotation
func.func @testFunctionInclude(%arg0: tensor<1xf32>, %arg1: tensor<1xf32>) {
  %0 = "tfl.add"(%arg0, %arg1) {fused_activation_function = "RELU6"} : (tensor<1xf32>, tensor<1xf32>) -> tensor<1xf32>
  func.return
}

// CHECK-LABEL: testOpFilter
func.func @testOpFilter(%arg0: tensor<1xf32>, %arg1: tensor<1xf32>) {
  // CHECK: tfl.add
  // CHECK-SAME: tac.skip_target_annotation
  %0 = "tfl.add"(%arg0, %arg1) {fused_activation_function = "RELU6"} : (tensor<1xf32>, tensor<1xf32>) -> tensor<1xf32> loc("test_op_0")
  // CHECK: tfl.add
  // CHECK-NOT: tac.skip_target_annotation
  %1 = "tfl.add"(%arg0, %0) {fused_activation_function = "RELU"} : (tensor<1xf32>, tensor<1xf32>) -> tensor<1xf32> loc("non_test_op")
  // CHECK: tfl.relu
  // CHECK-SAME: tac.skip_target_annotation
  %2 = "tfl.relu"(%arg0) : (tensor<1xf32>) -> tensor<1xf32> loc("test_op_1")
  func.return
}
