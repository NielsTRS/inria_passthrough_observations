#/bin/bash

sudo bpftrace -e '

kprobe:dma_direct_map_page {
  @page[tid] = arg1;
}

kretprobe:dma_direct_map_page
/@page[tid]/
{
  printf("CPU%d %lld [dma_direct_map_page] pid=%d %s -> dma_addr=%p page=%p\n", cpu, nsecs, pid, comm, retval, @page[tid]);
  print(kstack());
}

kprobe:dma_direct_map_sg {
  @page[tid] = arg1;
}

kretprobe:dma_direct_map_sg
/@page[tid]/
{
  printf("CPU%d %lld [dma_direct_map_sg] pid=%d %s -> dma_addr=%p page=%p\n", cpu, nsecs, pid, comm, retval, @page[tid]);
  print(kstack());
}

kprobe:dma_map_page_attrs {
  @page[tid] = arg1;
}

kretprobe:dma_map_page_attrs
/@page[tid]/
{
    printf("CPU%d %lld [dma_map_page_attrs] pid=%d %s -> dma_addr=%p page=%p\n", cpu, nsecs, pid, comm, retval, @page[tid]);
  print(kstack());
}

kprobe:dma_unmap_page_attrs
{
  printf("CPU%d %lld [dma_unmap_page_attrs] pid=%d %s -> dma_addr=%p size=%lu\n", cpu, nsecs, pid, comm, arg1, arg2);
  print(kstack());
}

kprobe:dma_map_sg_attrs
{
  @sgl[tid] = arg1;
}

kretprobe:dma_map_sg_attrs
/@sgl[tid] /
{
  $sg = (struct scatterlist *)@sgl[tid];
  $nents = retval;
  $time = nsecs;
  printf("CPU%d %lld [dma_map_sg_attrs] pid=%d %s -> %d segments\n", cpu, $time, pid, comm, $nents);
  print(kstack());

  if ($nents > 0) {
    $p = (struct page *)($sg[0].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 0] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[0].dma_address, $sg[0].dma_length, $p);
  }
  if ($nents > 1) {
    $p = (struct page *)($sg[1].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 1] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[1].dma_address, $sg[1].dma_length, $p);
  }
  if ($nents > 2) {
    $p = (struct page *)($sg[2].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 2] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[2].dma_address, $sg[2].dma_length, $p);
  }
  if ($nents > 3) {
    $p = (struct page *)($sg[3].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 3] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[3].dma_address, $sg[3].dma_length, $p);
  }
  if ($nents > 4) {
    $p = (struct page *)($sg[4].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 4] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[4].dma_address, $sg[4].dma_length, $p);
  }
  if ($nents > 5) {
    $p = (struct page *)($sg[5].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 5] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[5].dma_address, $sg[5].dma_length, $p);
  }
  if ($nents > 6) {
    $p = (struct page *)($sg[6].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 6] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[6].dma_address, $sg[6].dma_length, $p);
  }
  if ($nents > 7) {
    $p = (struct page *)($sg[7].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 7] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[7].dma_address, $sg[7].dma_length, $p);
  }
  if ($nents > 8) {
    $p = (struct page *)($sg[8].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 8] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[8].dma_address, $sg[8].dma_length, $p);
  }
  if ($nents > 9) {
    $p = (struct page *)($sg[9].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 9] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[9].dma_address, $sg[9].dma_length, $p);
  }
  if ($nents > 10) {
    $p = (struct page *)($sg[10].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 10] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[10].dma_address, $sg[10].dma_length, $p);
  }
  if ($nents > 11) {
    $p = (struct page *)($sg[11].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 11] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[11].dma_address, $sg[11].dma_length, $p);
  }
  if ($nents > 12) {
    $p = (struct page *)($sg[12].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 12] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[12].dma_address, $sg[12].dma_length, $p);
  }
  if ($nents > 13) {
    $p = (struct page *)($sg[13].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 13] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[13].dma_address, $sg[13].dma_length, $p);
  }
  if ($nents > 14) {
    $p = (struct page *)($sg[14].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 14] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[14].dma_address, $sg[14].dma_length, $p);
  }
  if ($nents > 15) {
    $p = (struct page *)($sg[15].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 15] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[15].dma_address, $sg[15].dma_length, $p);
  }
  if ($nents > 16) {
    $p = (struct page *)($sg[16].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 16] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[16].dma_address, $sg[16].dma_length, $p);
  }
  if ($nents > 17) {
    $p = (struct page *)($sg[17].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 17] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[17].dma_address, $sg[17].dma_length, $p);
  }
  if ($nents > 18) {
    $p = (struct page *)($sg[18].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 18] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[18].dma_address, $sg[18].dma_length, $p);
  }
  if ($nents > 19) {
    $p = (struct page *)($sg[19].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 19] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[19].dma_address, $sg[19].dma_length, $p);
  }
  if ($nents > 20) {
    $p = (struct page *)($sg[20].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 20] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[20].dma_address, $sg[20].dma_length, $p);
  }
  if ($nents > 21) {
    $p = (struct page *)($sg[21].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 21] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[21].dma_address, $sg[21].dma_length, $p);
  }
  if ($nents > 22) {
    $p = (struct page *)($sg[22].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 22] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[22].dma_address, $sg[22].dma_length, $p);
  }
  if ($nents > 23) {
    $p = (struct page *)($sg[23].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 23] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[23].dma_address, $sg[23].dma_length, $p);
  }
  if ($nents > 24) {
    $p = (struct page *)($sg[24].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 24] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[24].dma_address, $sg[24].dma_length, $p);
  }
  if ($nents > 25) {
    $p = (struct page *)($sg[25].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 25] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[25].dma_address, $sg[25].dma_length, $p);
  }
  if ($nents > 26) {
    $p = (struct page *)($sg[26].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 26] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[26].dma_address, $sg[26].dma_length, $p);
  }
  if ($nents > 27) {
    $p = (struct page *)($sg[27].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 27] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[27].dma_address, $sg[27].dma_length, $p);
  }
  if ($nents > 28) {
    $p = (struct page *)($sg[28].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 28] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[28].dma_address, $sg[28].dma_length, $p);
  }
  if ($nents > 29) {
    $p = (struct page *)($sg[29].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 29] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[29].dma_address, $sg[29].dma_length, $p);
  }
  if ($nents > 30) {
    $p = (struct page *)($sg[30].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 30] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[30].dma_address, $sg[30].dma_length, $p);
  }
  if ($nents > 31) {
    $p = (struct page *)($sg[31].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 31] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[31].dma_address, $sg[31].dma_length, $p);
  }
  if ($nents > 32) {
    $p = (struct page *)($sg[32].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sg_attrs 32] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[32].dma_address, $sg[32].dma_length, $p);
  }

  delete(@sgl[tid]);
}

kprobe:dma_unmap_sg_attrs
{
  $sg = (struct scatterlist *)arg1;
  $nents = arg2;
  $valid = 0;
  $time = nsecs;

  if ($nents > 0 && $sg[0].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 1 && $sg[1].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 2 && $sg[2].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 3 && $sg[3].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 4 && $sg[4].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 5 && $sg[5].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 6 && $sg[6].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 7 && $sg[7].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 8 && $sg[8].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 9 && $sg[9].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 10 && $sg[10].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 11 && $sg[11].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 12 && $sg[12].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 13 && $sg[13].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 14 && $sg[14].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 15 && $sg[15].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 16 && $sg[16].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 17 && $sg[17].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 18 && $sg[18].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 19 && $sg[19].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 20 && $sg[20].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 21 && $sg[21].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 22 && $sg[22].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 23 && $sg[23].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 24 && $sg[24].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 25 && $sg[25].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 26 && $sg[26].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 27 && $sg[27].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 28 && $sg[28].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 29 && $sg[29].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 30 && $sg[30].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 31 && $sg[31].dma_address != (uint64)0xffffffffffffffff) { $valid++; }
  if ($nents > 32 && $sg[32].dma_address != (uint64)0xffffffffffffffff) { $valid++; }

  printf("CPU%d %lld [dma_unmap_sg_attrs] pid=%d %s %lu segments (%lu asked)\n", cpu, $time, pid, comm, $valid, $nents);
  print(kstack());

  if ($nents > 0) {
    $p = (struct page *)($sg[0].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 0] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[0].dma_address, $sg[0].dma_length, $p);
  }
  if ($nents > 1) {
    $p = (struct page *)($sg[1].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 1] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[1].dma_address, $sg[1].dma_length, $p);
  }
  if ($nents > 2) {
     $p = (struct page *)($sg[2].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 2] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[2].dma_address, $sg[2].dma_length, $p);
  }
  if ($nents > 3) {
     $p = (struct page *)($sg[3].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 3] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[3].dma_address, $sg[3].dma_length, $p);
  }
  if ($nents > 4) {
     $p = (struct page *)($sg[4].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 4] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[4].dma_address, $sg[4].dma_length, $p);
  }
  if ($nents > 5) {
     $p = (struct page *)($sg[5].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 5] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[5].dma_address, $sg[5].dma_length, $p);
  }
  if ($nents > 6) {
     $p = (struct page *)($sg[6].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 6] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[6].dma_address, $sg[6].dma_length, $p);
  }
  if ($nents > 7) {
     $p = (struct page *)($sg[7].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 7] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[7].dma_address, $sg[7].dma_length, $p);
  }
  if ($nents > 8) {
     $p = (struct page *)($sg[8].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 8] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[8].dma_address, $sg[8].dma_length, $p);
  }
  if ($nents > 9) {
     $p = (struct page *)($sg[9].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 9] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[9].dma_address, $sg[9].dma_length, $p);
  }
  if ($nents > 10) {
     $p = (struct page *)($sg[10].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 10] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[10].dma_address, $sg[10].dma_length, $p);
  }
  if ($nents > 11) {
     $p = (struct page *)($sg[11].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 11] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[11].dma_address, $sg[11].dma_length, $p);
  }
  if ($nents > 12) {
     $p = (struct page *)($sg[12].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 12] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[12].dma_address, $sg[12].dma_length, $p);
  }
  if ($nents > 13) {
     $p = (struct page *)($sg[13].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 13] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[13].dma_address, $sg[13].dma_length, $p);
  }
  if ($nents > 14) {
     $p = (struct page *)($sg[14].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 14] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[14].dma_address, $sg[14].dma_length, $p);
  }
  if ($nents > 15) {
     $p = (struct page *)($sg[15].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 15] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[15].dma_address, $sg[15].dma_length, $p);
  }
  if ($nents > 16) {
     $p = (struct page *)($sg[16].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 16] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[16].dma_address, $sg[16].dma_length, $p);
  }
  if ($nents > 17) {
     $p = (struct page *)($sg[17].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 17] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[17].dma_address, $sg[17].dma_length, $p);
  }
  if ($nents > 18) {
     $p = (struct page *)($sg[18].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 18] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[18].dma_address, $sg[18].dma_length, $p);
  }
  if ($nents > 19) {
     $p = (struct page *)($sg[19].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 19] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[19].dma_address, $sg[19].dma_length, $p);
  }
  if ($nents > 20) {
     $p = (struct page *)($sg[20].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 20] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[20].dma_address, $sg[20].dma_length, $p);
  }
  if ($nents > 21) {
     $p = (struct page *)($sg[21].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 21] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[21].dma_address, $sg[21].dma_length, $p);
  }
  if ($nents > 22) {
     $p = (struct page *)($sg[22].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 22] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[22].dma_address, $sg[22].dma_length, $p);
  }
  if ($nents > 23) {
     $p = (struct page *)($sg[23].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 23] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[23].dma_address, $sg[23].dma_length, $p);
  }
  if ($nents > 24) {
     $p = (struct page *)($sg[24].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 24] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[24].dma_address, $sg[24].dma_length, $p);
  }
  if ($nents > 25) {
     $p = (struct page *)($sg[25].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 25] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[25].dma_address, $sg[25].dma_length, $p);
  }
  if ($nents > 26) {
     $p = (struct page *)($sg[26].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 26] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[26].dma_address, $sg[26].dma_length, $p);
  }
  if ($nents > 27) {
     $p = (struct page *)($sg[27].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 27] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[27].dma_address, $sg[27].dma_length, $p);
  }
  if ($nents > 28) {
     $p = (struct page *)($sg[28].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 28] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[28].dma_address, $sg[28].dma_length, $p);
  }
  if ($nents > 29) {
     $p = (struct page *)($sg[29].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 29] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[29].dma_address, $sg[29].dma_length, $p);
  }
  if ($nents > 30) {
     $p = (struct page *)($sg[30].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 30] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[30].dma_address, $sg[30].dma_length, $p);
  }
  if ($nents > 31) {
     $p = (struct page *)($sg[31].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 31] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[31].dma_address, $sg[31].dma_length, $p);
  }
  if ($nents > 32) {
     $p = (struct page *)($sg[32].page_link & ~3);
    printf("CPU%d %lld  [dma_unmap_sg_attrs 32] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[32].dma_address, $sg[32].dma_length, $p);
  }
}

kretprobe:dmam_alloc_attrs
/ cpu == 0 /
{
  printf("CPU%d %lld [dmam_alloc_attrs] pid=%d %s -> dma_addr=0x%lx\n", cpu, nsecs, pid, comm, retval);
}

kprobe:dma_free_attrs
/ cpu == 0 /
{
  printf("CPU%d %lld [dma_free_attrs] pid=%d %s dma_addr=0x%lx size=%lu\n", cpu, nsecs, pid, comm, arg1, arg2);
}

kprobe:dma_map_sgtable
{
  @table[tid] = arg1;
}

kretprobe:dma_map_sgtable
/@table[tid]/
{
  $table = (struct sg_table *)@table[tid];
  $sg = $table->sgl;
  $nents = $table->nents;
  $orig_nents = $table->orig_nents;
  $time = nsecs;
  printf("CPU%d %lld [dma_map_sgtable] pid=%d %s -> %d segments (%d asked)\n", cpu, $time, pid, comm, $nents, $orig_nents);
  print(kstack());

  if ($nents > 0) {
     $p = (struct page *)($sg[0].page_link & ~3);
    printf("CPU%d %lld   [dma_map_sgtable 0] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[0].dma_address, $sg[0].dma_length, $p);
  }
  if ($nents > 1) {
     $p = (struct page *)($sg[1].page_link & ~3);
    printf("CPU%d %lld   [dma_map_sgtable 1] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[1].dma_address, $sg[1].dma_length, $p);
  }
  if ($nents > 2) {
     $p = (struct page *)($sg[2].page_link & ~3);
    printf("CPU%d %lld   [dma_map_sgtable 2] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[2].dma_address, $sg[2].dma_length, $p);
  }
  if ($nents > 3) {
     $p = (struct page *)($sg[3].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 3] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[3].dma_address, $sg[3].dma_length, $p);
  }
  if ($nents > 4) {
     $p = (struct page *)($sg[4].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 4] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[4].dma_address, $sg[4].dma_length, $p);
  }
  if ($nents > 5) {
     $p = (struct page *)($sg[5].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 5] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[5].dma_address, $sg[5].dma_length, $p);
  }
  if ($nents > 6) {
     $p = (struct page *)($sg[6].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 6] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[6].dma_address, $sg[6].dma_length, $p);
  }
  if ($nents > 7) {
     $p = (struct page *)($sg[7].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 7] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[7].dma_address, $sg[7].dma_length, $p);
  }
  if ($nents > 8) {
     $p = (struct page *)($sg[8].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 8] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[8].dma_address, $sg[8].dma_length, $p);
  }
  if ($nents > 9) {
     $p = (struct page *)($sg[9].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 9] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[9].dma_address, $sg[9].dma_length, $p);
  }
  if ($nents > 10) {
     $p = (struct page *)($sg[10].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 10] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[10].dma_address, $sg[10].dma_length, $p);
  }
  if ($nents > 11) {
     $p = (struct page *)($sg[11].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 11] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[11].dma_address, $sg[11].dma_length, $p);
  }
  if ($nents > 12) {
     $p = (struct page *)($sg[12].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 12] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[12].dma_address, $sg[12].dma_length, $p);
  }
  if ($nents > 13) {
     $p = (struct page *)($sg[13].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 13] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[13].dma_address, $sg[13].dma_length, $p);
  }
  if ($nents > 14) {
     $p = (struct page *)($sg[14].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 14] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[14].dma_address, $sg[14].dma_length, $p);
  }
  if ($nents > 15) {
     $p = (struct page *)($sg[15].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 15] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[15].dma_address, $sg[15].dma_length, $p);
  }
  if ($nents > 16) {
     $p = (struct page *)($sg[16].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 16] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[16].dma_address, $sg[16].dma_length, $p);
  }
  if ($nents > 17) {
     $p = (struct page *)($sg[17].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 17] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[17].dma_address, $sg[17].dma_length, $p);
  }
  if ($nents > 18) {
     $p = (struct page *)($sg[18].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 18] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[18].dma_address, $sg[18].dma_length, $p);
  }
  if ($nents > 19) {
     $p = (struct page *)($sg[19].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 19] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[19].dma_address, $sg[19].dma_length, $p);
  }
  if ($nents > 20) {
     $p = (struct page *)($sg[20].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 20] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[20].dma_address, $sg[20].dma_length, $p);
  }
  if ($nents > 21) {
     $p = (struct page *)($sg[21].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 21] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[21].dma_address, $sg[21].dma_length, $p);
  }
  if ($nents > 22) {
     $p = (struct page *)($sg[22].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 22] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[22].dma_address, $sg[22].dma_length, $p);
  }
  if ($nents > 23) {
     $p = (struct page *)($sg[23].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 23] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[23].dma_address, $sg[23].dma_length, $p);
  }
  if ($nents > 24) {
     $p = (struct page *)($sg[24].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 24] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[24].dma_address, $sg[24].dma_length, $p);
  }
  if ($nents > 25) {
     $p = (struct page *)($sg[25].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 25] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[25].dma_address, $sg[25].dma_length, $p);
  }
  if ($nents > 26) {
     $p = (struct page *)($sg[26].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 26] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[26].dma_address, $sg[26].dma_length, $p);
  }
  if ($nents > 27) {
     $p = (struct page *)($sg[27].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 27] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[27].dma_address, $sg[27].dma_length, $p);
  }
  if ($nents > 28) {
     $p = (struct page *)($sg[28].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 28] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[28].dma_address, $sg[28].dma_length, $p);
  }
  if ($nents > 29) {
     $p = (struct page *)($sg[29].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 29] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[29].dma_address, $sg[29].dma_length, $p);
  }
  if ($nents > 30) {
     $p = (struct page *)($sg[30].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 30] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[30].dma_address, $sg[30].dma_length, $p);
  }
  if ($nents > 31) {
     $p = (struct page *)($sg[31].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 31] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[31].dma_address, $sg[31].dma_length, $p);
  }
  if ($nents > 32) {
     $p = (struct page *)($sg[32].page_link & ~3);
    printf("CPU%d %lld  [dma_map_sgtable 32] dma=0x%lx len=%u page=%p\n", cpu, $time, $sg[32].dma_address, $sg[32].dma_length, $p);
  }

  delete(@table[tid]);
}
'
