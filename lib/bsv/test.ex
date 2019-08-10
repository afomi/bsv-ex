defmodule BSV.Test do
  @moduledoc """
  A variety of helper functions to make the tests consistent
  in their usage of keys, etc.

  Please don't use these keys for anything other than testing.
  """

  @doc """
  Returns a generic symetric key.
  """
  def symetric_key do
    <<225, 142, 18, 176, 144, 89, 142, 193, 18, 237, 201, 84, 109, 62, 36, 67, 233,
      244, 170, 233, 98, 100, 18, 201, 118, 69, 91, 182, 242, 255, 173, 106>>
  end

  @doc """
  Returns an initialization vector of 12 bytes (96 bit).
  """
  def iv12 do
    <<50, 75, 191, 85, 4, 124, 185, 253, 212, 34, 64, 169>>
  end

  @doc """
  Returns an initialization vector of 16 bytes (128 bit).
  """
  def iv16 do
    <<245, 64, 39, 93, 45, 251, 164, 144, 160, 20, 159, 238, 26, 236, 140, 161>>
  end

  @doc """
  Returns a generic RSA public key (raw erlang style).
  """
  def rsa_public_key do
    [e, n | _] = rsa_private_key
    [e, n]
  end

  @doc """
  Returns a generic RSA private key (raw erlang style).
  """
  def rsa_private_key do
    [
      <<1, 0, 1>>,
      <<186, 151, 5, 2, 197, 129, 89, 197, 98, 89, 140, 6, 200, 138, 135, 2, 82, 89,
        84, 137, 156, 152, 216, 217, 120, 86, 207, 31, 145, 134, 230, 79, 241, 175,
        110, 254, 224, 45, 243, 140, 56, 216, 57, 35, 242, 179, 14, 160, 124, 206,
        125, 244, 3, 1, 179, 255, 149, 51, 39, 139, 198, 254, 178, 240, 87, 154,
        137, 189, 245, 200, 104, 125, 175, 93, 53, 153, 117, 151, 126, 182, 29, 145, 
        122, 26, 188, 42, 187, 27, 10, 228, 230, 109, 133, 69, 1, 184, 69, 153, 28,
        47, 235, 228, 244, 227, 121, 173, 153, 32, 176, 60, 31, 27, 151, 242, 129,
        175, 139, 92, 126, 66, 185, 71, 23, 82, 3, 97, 20, 46, 54, 109, 204, 159,
        164, 200, 66, 133, 149, 71, 244, 227, 216, 153, 3, 21, 126, 105, 145, 149,
        222, 143, 122, 123, 140, 68, 252, 26, 196, 236, 66, 114, 67, 113, 110, 149,
        198, 43, 232, 52, 225, 32, 108, 11, 140, 112, 59, 106, 232, 8, 241, 179, 56,
        165, 114, 227, 167, 28, 20, 26, 3, 183, 129, 249, 78, 92, 149, 80, 6, 8,
        197, 58, 237, 191, 165, 0, 102, 236, 100, 84, 171, 78, 111, 108, 116, 232,
        152, 133, 115, 49, 27, 118, 190, 203, 138, 99, 54, 140, 228, 32, 42, 89,
        157, 90, 46, 201, 133, 164, 201, 96, 5, 241, 11, 151, 237, 226, 10, 69, 72,
        87, 28, 6, 145, 2, 24, 18, 172, 165>>,
      <<164, 65, 224, 2, 97, 150, 14, 78, 9, 215, 100, 194, 111, 246, 43, 5, 235,
        50, 130, 142, 38, 18, 20, 11, 213, 185, 45, 218, 207, 132, 158, 233, 79,
        140, 173, 188, 167, 227, 43, 220, 140, 10, 36, 187, 53, 163, 85, 68, 8, 186,
        202, 252, 109, 77, 41, 132, 220, 118, 76, 224, 234, 204, 59, 0, 3, 78, 162,
        229, 92, 34, 17, 130, 91, 71, 69, 177, 19, 104, 202, 254, 77, 39, 77, 3,
        142, 20, 91, 228, 97, 129, 194, 44, 53, 190, 218, 213, 186, 71, 32, 30, 59,
        158, 177, 202, 50, 202, 148, 219, 198, 233, 22, 69, 119, 76, 223, 199, 134,
        122, 101, 24, 29, 252, 172, 85, 225, 109, 171, 145, 197, 249, 78, 158, 207,
        124, 170, 140, 202, 232, 23, 160, 51, 222, 229, 7, 35, 77, 102, 88, 112,
        254, 239, 154, 62, 30, 249, 142, 181, 255, 29, 143, 75, 239, 144, 25, 194,
        93, 234, 59, 220, 72, 118, 218, 209, 82, 84, 204, 191, 226, 75, 174, 238,
        79, 9, 139, 68, 210, 208, 249, 183, 63, 87, 125, 123, 2, 187, 163, 62, 252,
        177, 80, 82, 111, 243, 147, 101, 98, 188, 125, 116, 188, 25, 188, 159, 68,
        246, 199, 20, 109, 75, 190, 12, 90, 27, 58, 86, 205, 195, 230, 37, 144, 15,
        207, 215, 143, 25, 176, 183, 243, 80, 197, 196, 31, 29, 190, 241, 154, 65,
        251, 220, 168, 113, 229, 185, 26, 76, 189>>, 
      <<227, 17, 99, 221, 241, 247, 86, 17, 4, 212, 202, 63, 56, 216, 43, 173, 72,
        249, 95, 195, 251, 184, 205, 8, 90, 241, 205, 62, 166, 8, 153, 216, 239,
        190, 114, 43, 124, 182, 230, 170, 107, 60, 44, 190, 92, 179, 188, 176, 75,
        146, 199, 49, 204, 195, 33, 248, 105, 180, 249, 62, 13, 62, 3, 233, 19, 119,
        48, 100, 140, 146, 211, 211, 36, 129, 163, 255, 141, 236, 141, 73, 93, 152,
        236, 210, 149, 200, 134, 3, 190, 212, 65, 25, 122, 42, 6, 166, 150, 69, 239,
        201, 191, 200, 228, 209, 28, 34, 54, 254, 133, 73, 235, 175, 58, 42, 106,
        137, 68, 116, 33, 178, 55, 73, 110, 66, 4, 244, 29, 151>>,
      <<210, 93, 76, 104, 5, 69, 159, 187, 147, 147, 0, 111, 49, 74, 140, 102, 45,
        239, 214, 198, 198, 12, 63, 4, 194, 69, 172, 70, 202, 88, 184, 111, 10, 186,
        141, 40, 103, 145, 227, 218, 29, 196, 9, 84, 98, 9, 98, 57, 55, 145, 6, 221,
        67, 167, 226, 250, 192, 62, 148, 131, 134, 221, 8, 252, 142, 176, 80, 6, 86,
        227, 224, 17, 163, 45, 145, 115, 246, 212, 163, 163, 45, 102, 18, 102, 182,
        210, 196, 10, 195, 40, 204, 106, 155, 43, 166, 36, 58, 65, 55, 230, 101, 36,
        92, 93, 92, 13, 4, 119, 195, 205, 238, 114, 141, 158, 39, 182, 84, 203, 76,
        205, 223, 149, 244, 223, 92, 168, 135, 35>>,
      <<175, 161, 108, 208, 103, 238, 186, 136, 113, 103, 49, 132, 19, 48, 201, 31,
        192, 88, 250, 164, 185, 88, 40, 102, 181, 9, 96, 138, 123, 156, 29, 123,
        121, 124, 162, 12, 86, 235, 149, 160, 237, 78, 223, 0, 226, 237, 55, 30, 89,
        102, 15, 98, 202, 145, 135, 253, 255, 173, 54, 55, 179, 192, 106, 255, 229,
        201, 132, 9, 209, 221, 99, 176, 102, 5, 76, 87, 71, 108, 87, 160, 14, 160,
        81, 85, 84, 251, 132, 4, 243, 158, 115, 56, 4, 144, 235, 18, 1, 27, 217, 44,
        0, 134, 159, 205, 202, 104, 0, 135, 127, 139, 60, 156, 13, 110, 111, 118,
        251, 22, 164, 85, 151, 131, 217, 159, 128, 251, 92, 195>>,
      <<58, 140, 60, 247, 182, 127, 234, 53, 10, 157, 159, 65, 83, 54, 172, 92, 195,
        236, 60, 154, 150, 4, 82, 133, 192, 140, 35, 166, 144, 42, 161, 42, 70, 146,
        37, 55, 89, 156, 1, 14, 115, 186, 91, 222, 96, 106, 188, 43, 176, 139, 108,
        157, 168, 118, 209, 117, 120, 139, 242, 73, 168, 255, 91, 192, 238, 245,
        163, 80, 32, 94, 203, 190, 28, 236, 81, 207, 52, 163, 121, 231, 176, 122,
        248, 36, 30, 62, 10, 209, 243, 255, 38, 229, 132, 202, 97, 51, 52, 3, 114,
        203, 108, 218, 241, 218, 10, 4, 149, 121, 191, 197, 80, 216, 17, 18, 51,
        123, 75, 158, 73, 130, 2, 248, 121, 110, 177, 27, 54, 129>>,
      <<90, 222, 229, 130, 91, 120, 192, 72, 33, 56, 40, 238, 125, 124, 60, 226,
        191, 196, 194, 176, 181, 254, 231, 96, 236, 85, 187, 28, 104, 208, 215, 233,
        73, 145, 204, 203, 20, 206, 173, 94, 37, 32, 124, 229, 175, 184, 19, 184,
        37, 45, 226, 41, 116, 163, 94, 59, 208, 163, 100, 208, 88, 60, 188, 137, 96,
        74, 197, 87, 141, 121, 54, 93, 18, 203, 223, 186, 110, 155, 157, 127, 69,
        24, 216, 85, 98, 117, 248, 9, 13, 229, 80, 251, 173, 24, 8, 156, 25, 119,
        250, 143, 139, 251, 33, 44, 90, 174, 171, 168, 211, 103, 6, 137, 116, 225,
        158, 224, 143, 68, 147, 183, 36, 213, 211, 62, 25, 226, 192, 158>>
    ]
  end
  
end